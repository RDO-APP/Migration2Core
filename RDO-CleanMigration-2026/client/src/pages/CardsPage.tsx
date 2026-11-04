import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { fetchCardsContext } from '../api/cardsApi'
import type { EtapaComTarefas, TarefaCard } from '../api/equipamentos-api.types'
import { AddTarefaPlaceholder, TaskCardAgrupador } from '../components/TaskCardAgrupador'
import { CardsToolbar } from '../components/CardsToolbar'
import { NovaMedicaoModal } from '../components/NovaMedicaoModal'
import { RelatorioHorasEquipamentoModal } from '../components/RelatorioHorasEquipamentoModal'
import { HistoricoMedicaoModal } from '../components/HistoricoMedicaoModal'
import { AlterarStatusMassaModal } from '../components/AlterarStatusMassaModal'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import {
  EMPTY_FILTRO,
  aplicarFiltroEtapas,
  type CardsFiltroState,
} from '../cardsFiltro'
import '../cards-page.css'
import '../tarefa-cadastro.css'

function filtroFromUrl(): boolean {
  if (typeof window === 'undefined') return false
  return new URLSearchParams(window.location.search).get('filtro') === '1'
}

export function CardsPage() {
  const { shell } = useShellContext()
  const [data, setData] = useState<Awaited<ReturnType<typeof fetchCardsContext>> | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [openEtapas, setOpenEtapas] = useState<Set<number>>(() => new Set())
  const [filtroOpen, setFiltroOpen] = useState(filtroFromUrl)
  const [selectedIds, setSelectedIds] = useState<Set<number>>(() => new Set())
  const [massaOpen, setMassaOpen] = useState(false)
  const [medicao, setMedicao] = useState<TarefaCard | null>(null)
  const [relatorioHoras, setRelatorioHoras] = useState<TarefaCard | null>(null)
  const [historico, setHistorico] = useState<TarefaCard | null>(null)
  const [filtroDraft, setFiltroDraft] = useState<CardsFiltroState>(EMPTY_FILTRO)
  const [filtroAplicado, setFiltroAplicado] = useState<CardsFiltroState>(EMPTY_FILTRO)

  const etapasVisiveis = useMemo(() => {
    if (!data) return [] as EtapaComTarefas[]
    return aplicarFiltroEtapas(data.etapas, filtroAplicado)
  }, [data, filtroAplicado])

  const allTarefaIds = useMemo(
    () => etapasVisiveis.flatMap((e) => e.tarefas.map((t) => t.id)),
    [etapasVisiveis],
  )

  const selectAll =
    allTarefaIds.length > 0 && allTarefaIds.every((id) => selectedIds.has(id))

  useEffect(() => {
    setFiltroOpen(filtroFromUrl())
    const hid = Number(new URLSearchParams(window.location.search).get('historico'))
    if (Number.isFinite(hid) && hid > 0) {
      setHistorico({ id: hid, descricao: '', status: 0, nomeStatus: '', idEtapa: 0 })
    }
  }, [])

  useEffect(() => {
    let cancelled = false
    fetchCardsContext()
      .then((ctx) => {
        if (!cancelled) {
          setData(ctx)
          setOpenEtapas(new Set())
          setSelectedIds(new Set())
        }
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : 'Falha ao carregar.')
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  function toggleEtapa(id: number) {
    setOpenEtapas((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  function onToggleFiltro() {
    setFiltroOpen((open) => {
      const next = !open
      window.history.replaceState({}, '', next ? '/Tarefa/Cards?filtro=1' : '/Tarefa/Cards')
      return next
    })
  }

  function onPesquisarFiltro() {
    setFiltroAplicado({ ...filtroDraft })
    if (data) {
      const ids = aplicarFiltroEtapas(data.etapas, filtroDraft).map((e) => e.id)
      setOpenEtapas(new Set(ids))
    }
  }

  function onSelectAllChange(checked: boolean) {
    if (checked) setSelectedIds(new Set(allTarefaIds))
    else setSelectedIds(new Set())
  }

  function onToggleSelect(tarefaId: number, selected: boolean) {
    setSelectedIds((prev) => {
      const next = new Set(prev)
      if (selected) next.add(tarefaId)
      else next.delete(tarefaId)
      return next
    })
  }

  function onAbrirStatusMassa() {
    if (selectedIds.size === 0) {
      showToast('error', 'Selecione ao menos uma tarefa.')
      return
    }
    setMassaOpen(true)
  }

  const shellWrap = (body: ReactNode) => (
    <OperadorShell variant="cards" obraNome={data?.obraNome} shell={shell}>
      {body}
    </OperadorShell>
  )

  if (loading) {
    return shellWrap(
      <section className="cards-page">
        <p className="muted cards-loading">Carregando tarefas…</p>
      </section>,
    )
  }

  if (error) {
    return shellWrap(
      <section className="cards-page">
        <p className="error">{error}</p>
        <p>
          <a href="/Obra/Escolher">Escolher obra</a>
        </p>
      </section>,
    )
  }

  if (!data) {
    return null
  }

  return shellWrap(
    <section className="cards-page">
      {selectedIds.size > 0 ? (
        <div className="contador-selecionados active" aria-live="polite">
          <i className="fa fa-check" aria-hidden="true" />
          <strong>{selectedIds.size}</strong> selecionada(s)
        </div>
      ) : null}
      <CardsToolbar
        filtroOpen={filtroOpen}
        onToggleFiltro={onToggleFiltro}
        onNovaTarefa={() => goOperador(P3_NAV.toolbar.adicionarTarefa)}
        onNovaEtapa={() => goOperador(P3_NAV.toolbar.adicionarEtapa)}
        onLista={() => goOperador(P3_NAV.toolbar.listaTarefas)}
        onGerarRdo={() => goOperador(P3_NAV.toolbar.gerarRdo)}
        onEfetivoDiario={() => goOperador(P3_NAV.toolbar.efetivoDiario)}
        onEditarObra={() => goOperador(P3_NAV.toolbar.editarObra)}
        showGerarRdo={
          shell != null && typeof shell.showGerarRdo === 'boolean' ? shell.showGerarRdo : false
        }
        showEditarObra={
          shell != null && typeof shell.showEditarObra === 'boolean' ? shell.showEditarObra : false
        }
        showCriarNovoTarefa={shell?.showCriarNovoTarefa === true}
        showCriarNovaEtapa={shell?.showCriarNovaEtapa === true}
        filtroDraft={filtroDraft}
        onFiltroDraftChange={setFiltroDraft}
        onPesquisarFiltro={onPesquisarFiltro}
        etapasOpts={data.etapas.map((e) => ({ id: e.id, titulo: e.titulo }))}
      />

      {etapasVisiveis.length === 0 ? (
        <label className="col-xs-12 no-padding cards-empty-label">
          {data.etapas.length === 0
            ? 'Nenhum registro encontrado.'
            : 'Nenhuma tarefa correspondente ao filtro.'}
        </label>
      ) : (
        <>
          <div className="cards-select-all-row">
            <div id="selecionar-tudo" className="checkbox cards-select-all">
              <label>
                <input
                  type="checkbox"
                  checked={selectAll}
                  onChange={(e) => onSelectAllChange(e.target.checked)}
                />
                SELECIONAR TUDO
              </label>
            </div>
            {/* Prod: permission aterarStatusEmMassa. Homolog: sempre ao lado de SELECIONAR TUDO
                (RBAC fino depois — senão some e o smoke não acha o controle). */}
            <button
              type="button"
              className="btn btn-blue btn-menor cards-alterar-status-massa"
              onClick={onAbrirStatusMassa}
              title={
                shell?.showAlterarStatusEmMassa === false
                  ? 'Homolog: visível para smoke (prod exige aterarStatusEmMassa)'
                  : 'Alterar status em massa'
              }
            >
              <i className="fa fa-play-circle" aria-hidden />
              alterar status em massa
            </button>
          </div>

          <div className="lista-tarefas">
            <div className="panel-group accordion" id="accordion">
              {etapasVisiveis.map((etapa: EtapaComTarefas) => {
                const open = openEtapas.has(etapa.id)
                return (
                  <div key={etapa.id} className="panel panel-default">
                    <div className="panel-heading">
                      <h4 className={`panel-title expand ${open ? 'active' : ''}`}>
                        <button type="button" className="accordion-etapa-btn" onClick={() => toggleEtapa(etapa.id)}>
                          {etapa.titulo}
                        </button>
                      </h4>
                    </div>
                    {open ? (
                      <div className="panel-etapa-body">
                        <div className="panel-body">
                          {etapa.tarefas.length === 0 ? (
                            <>
                              <div className="etapa-empty-msg">Nenhuma tarefa adicionada nesta etapa.</div>
                              <AddTarefaPlaceholder etapaId={etapa.id} />
                            </>
                          ) : (
                            <>
                              {etapa.tarefas.map((t) => (
                                <TaskCardAgrupador
                                  key={t.id}
                                  tarefa={t}
                                  etapaId={etapa.id}
                                  selected={selectedIds.has(t.id)}
                                  onToggleSelect={onToggleSelect}
                                  onNovaMedicao={setMedicao}
                                  onRelatorioHoras={setRelatorioHoras}
                                  onHistorico={setHistorico}
                                  onStatusChanged={() => window.location.reload()}
                                />
                              ))}
                              <AddTarefaPlaceholder etapaId={etapa.id} />
                            </>
                          )}
                        </div>
                      </div>
                    ) : null}
                  </div>
                )
              })}
            </div>
          </div>
        </>
      )}
      {medicao ? (
        <NovaMedicaoModal
          tarefaId={medicao.id}
          descricaoTarefa={medicao.descricao}
          onClose={() => setMedicao(null)}
          onSaved={() => {
            setMedicao(null)
            window.location.reload()
          }}
        />
      ) : null}
      {relatorioHoras ? (
        <RelatorioHorasEquipamentoModal
          tarefaId={relatorioHoras.id}
          descricaoTarefa={relatorioHoras.descricao}
          onClose={() => setRelatorioHoras(null)}
        />
      ) : null}
      {historico ? (
        <HistoricoMedicaoModal
          tarefaId={historico.id}
          descricaoTarefa={historico.descricao}
          onClose={() => {
            setHistorico(null)
            if (new URLSearchParams(window.location.search).has('historico')) {
              window.history.replaceState({}, '', '/Tarefa/Cards')
            }
          }}
        />
      ) : null}
      {massaOpen ? (
        <AlterarStatusMassaModal
          tarefaIds={[...selectedIds]}
          onClose={() => setMassaOpen(false)}
          onSaved={() => {
            setMassaOpen(false)
            window.location.reload()
          }}
        />
      ) : null}
    </section>,
  )
}
