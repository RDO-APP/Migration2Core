import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { fetchCardsContext } from '../api/cardsApi'
import type { EtapaComTarefas, TarefaCard } from '../api/equipamentos-api.types'
import { CardsToolbar } from '../components/CardsToolbar'
import { AlterarStatusMassaModal } from '../components/AlterarStatusMassaModal'
import { HistoricoMedicaoModal } from '../components/HistoricoMedicaoModal'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import { EMPTY_FILTRO, aplicarFiltroEtapas, type CardsFiltroState } from '../cardsFiltro'
import '../cards-page.css'

function filtroFromUrl(): boolean {
  return typeof window !== 'undefined' && new URLSearchParams(window.location.search).get('filtro') === '1'
}

export function TarefaIndexPage() {
  const { shell } = useShellContext()
  const [data, setData] = useState<Awaited<ReturnType<typeof fetchCardsContext>> | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [openEtapas, setOpenEtapas] = useState<Set<number>>(() => new Set())
  const [filtroOpen, setFiltroOpen] = useState(filtroFromUrl)
  const [filtroDraft, setFiltroDraft] = useState<CardsFiltroState>(EMPTY_FILTRO)
  const [filtroAplicado, setFiltroAplicado] = useState<CardsFiltroState>(EMPTY_FILTRO)
  const [selectedIds, setSelectedIds] = useState<Set<number>>(() => new Set())
  const [massaOpen, setMassaOpen] = useState(false)
  const [historico, setHistorico] = useState<TarefaCard | null>(null)

  const etapasVisiveis = useMemo(() => {
    if (!data) return [] as EtapaComTarefas[]
    return aplicarFiltroEtapas(data.etapas, filtroAplicado)
  }, [data, filtroAplicado])

  const allTarefaIds = useMemo(
    () => etapasVisiveis.flatMap((e) => e.tarefas.map((t) => t.id)),
    [etapasVisiveis],
  )
  const selectAll = allTarefaIds.length > 0 && allTarefaIds.every((id) => selectedIds.has(id))

  useEffect(() => {
    let cancelled = false
    fetchCardsContext()
      .then((ctx) => {
        if (cancelled) return
        setData(ctx)
        setOpenEtapas(new Set(ctx.etapas.map((e) => e.id)))
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar.')
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
      window.history.replaceState({}, '', next ? '/Tarefa/Index?filtro=1' : '/Tarefa/Index')
      return next
    })
  }

  function onPesquisarFiltro() {
    setFiltroAplicado({ ...filtroDraft })
    if (data) setOpenEtapas(new Set(aplicarFiltroEtapas(data.etapas, filtroDraft).map((e) => e.id)))
  }

  function reload() {
    fetchCardsContext().then((ctx) => {
      setData(ctx)
      setSelectedIds(new Set())
    })
  }

  const shellWrap = (body: ReactNode) => (
    <OperadorShell variant="cards" obraNome={data?.obraNome} shell={shell}>
      {body}
    </OperadorShell>
  )

  if (loading) return shellWrap(<section className="cards-page"><p className="muted">Carregando�</p></section>)
  if (error) return shellWrap(<section className="cards-page"><p className="error">{error}</p></section>)
  if (!data) return null

  return shellWrap(
    <section className="cards-page">
      {selectedIds.size > 0 ? (
        <div className="contador-selecionados active" aria-live="polite">
          <i className="fa fa-check" aria-hidden />
          <strong>{selectedIds.size}</strong> selecionada(s)
        </div>
      ) : null}
      <CardsToolbar
        viewToggle="lista"
        filtroOpen={filtroOpen}
        onToggleFiltro={onToggleFiltro}
        onNovaTarefa={() => goOperador(P3_NAV.toolbar.adicionarTarefa)}
        onNovaEtapa={() => goOperador(P3_NAV.toolbar.adicionarEtapa)}
        onLista={() => goOperador(P3_NAV.header.tarefaCards)}
        onGerarRdo={() => goOperador(P3_NAV.toolbar.gerarRdo)}
        onEfetivoDiario={() => goOperador(P3_NAV.toolbar.efetivoDiario)}
        onEditarObra={() => goOperador(P3_NAV.toolbar.editarObra)}
        showGerarRdo={shell != null && typeof shell.showGerarRdo === 'boolean' ? shell.showGerarRdo : false}
        showEditarObra={shell != null && typeof shell.showEditarObra === 'boolean' ? shell.showEditarObra : false}
        showCriarNovoTarefa={shell?.showCriarNovoTarefa === true}
        showCriarNovaEtapa={shell?.showCriarNovaEtapa === true}
        filtroDraft={filtroDraft}
        onFiltroDraftChange={setFiltroDraft}
        onPesquisarFiltro={onPesquisarFiltro}
        etapasOpts={data.etapas.map((e) => ({ id: e.id, titulo: e.titulo }))}
      />

      {etapasVisiveis.length === 0 ? (
        <label className="col-xs-12 no-padding cards-empty-label">
          {data.etapas.length === 0 ? 'Nenhum registro encontrado.' : 'Nenhuma tarefa correspondente ao filtro.'}
        </label>
      ) : (
        <>
          <div className="cards-select-all-row">
            <div id="selecionar-tudo" className="checkbox cards-select-all">
              <label>
                <input
                  type="checkbox"
                  checked={selectAll}
                  onChange={(e) =>
                    setSelectedIds(e.target.checked ? new Set(allTarefaIds) : new Set())
                  }
                />
                SELECIONAR TUDO
              </label>
            </div>
            <button
              type="button"
              className="btn btn-blue btn-menor cards-alterar-status-massa"
              onClick={() => {
                if (selectedIds.size === 0) {
                  showToast('error', 'Selecione ao menos uma tarefa.')
                  return
                }
                setMassaOpen(true)
              }}
            >
              <i className="fa fa-play-circle" aria-hidden />
              alterar status em massa
            </button>
          </div>

          <div className="lista-tarefas">
            <div className="panel-group accordion">
              {etapasVisiveis.map((etapa) => {
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
                            <div className="etapa-empty-msg">Nenhuma tarefa adicionada nesta etapa.</div>
                          ) : (
                            <div className="table-responsive">
                              <table className="table table-striped">
                                <thead>
                                  <tr>
                                    <th style={{ width: '2%' }} />
                                    <th style={{ width: '2%' }} />
                                    <th>DESCRI��O</th>
                                    <th className="d-none d-sm-table-cell">STATUS</th>
                                    <th className="d-none d-sm-table-cell">DATA INICIO</th>
                                    <th className="d-none d-sm-table-cell">DATA PREVIS�O FIM</th>
                                    <th style={{ textAlign: 'center' }} colSpan={3}>
                                      A��ES
                                    </th>
                                  </tr>
                                </thead>
                                <tbody>
                                  {etapa.tarefas.map((tarefa) => {
                                    const nav = P3_NAV.card(tarefa.id, etapa.id)
                                    const checked = selectedIds.has(tarefa.id)
                                    return (
                                      <tr key={tarefa.id}>
                                        <td>
                                          <div className="checkbox">
                                            <label>
                                              <input
                                                type="checkbox"
                                                checked={checked}
                                                onChange={(e) => {
                                                  setSelectedIds((prev) => {
                                                    const next = new Set(prev)
                                                    if (e.target.checked) next.add(tarefa.id)
                                                    else next.delete(tarefa.id)
                                                    return next
                                                  })
                                                }}
                                              />
                                            </label>
                                          </div>
                                        </td>
                                        <td>
                                          <span className={`status ${tarefa.classeStatusCss?.trim() || 'bg-cinza'}`} />
                                        </td>
                                        <td>{tarefa.descricao}</td>
                                        <td className="d-none d-sm-table-cell">{tarefa.nomeStatus}</td>
                                        <td className="d-none d-sm-table-cell">{tarefa.dataInicio || '�'}</td>
                                        <td className="d-none d-sm-table-cell">{tarefa.dataPrevisaoFim || '�'}</td>
                                        <td>
                                          <button
                                            type="button"
                                            className="btn btn-simple btn-just-icon"
                                            title="Visualizar"
                                            onClick={() => goOperador(nav.visualizar)}
                                          >
                                            <i className="fa fa-eye" aria-hidden />
                                          </button>
                                        </td>
                                        <td>
                                          <button
                                            type="button"
                                            className="btn btn-simple btn-just-icon"
                                            title="Hist�rico"
                                            onClick={() => setHistorico(tarefa)}
                                          >
                                            <i className="fa fa-clock-o" aria-hidden />
                                          </button>
                                        </td>
                                        <td>
                                          <button
                                            type="button"
                                            className="btn btn-simple btn-just-icon"
                                            title="Editar"
                                            onClick={() => goOperador(nav.editar)}
                                          >
                                            <i className="fa fa-edit" aria-hidden />
                                          </button>
                                        </td>
                                      </tr>
                                    )
                                  })}
                                </tbody>
                              </table>
                            </div>
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

      {massaOpen ? (
        <AlterarStatusMassaModal
          tarefaIds={[...selectedIds]}
          onClose={() => setMassaOpen(false)}
          onSaved={() => {
            setMassaOpen(false)
            reload()
          }}
        />
      ) : null}
      {historico ? (
        <HistoricoMedicaoModal
          tarefaId={historico.id}
          descricaoTarefa={historico.descricao}
          onClose={() => setHistorico(null)}
        />
      ) : null}
    </section>,
  )
}
