import { useEffect, useState, type ReactNode } from 'react'
import { fetchCardsContext } from '../api/cardsApi'
import type { EtapaComTarefas } from '../api/equipamentos-api.types'
import { AddTarefaPlaceholder, TaskCardAgrupador } from '../components/TaskCardAgrupador'
import { CardsToolbar } from '../components/CardsToolbar'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import '../cards-page.css'

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
  const [selectAll, setSelectAll] = useState(false)

  useEffect(() => {
    setFiltroOpen(filtroFromUrl())
  }, [])

  useEffect(() => {
    let cancelled = false
    fetchCardsContext()
      .then((ctx) => {
        if (!cancelled) {
          setData(ctx)
          setOpenEtapas(new Set())
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
    if (filtroOpen) {
      setFiltroOpen(false)
      window.history.replaceState({}, '', '/Tarefa/Cards')
      return
    }
    goOperador(P3_NAV.toolbar.filtroQuery)
  }

  function onSelectAllChange(checked: boolean) {
    setSelectAll(checked)
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
          shell != null && typeof shell.showGerarRdo === 'boolean' ? shell.showGerarRdo : true
        }
        showEditarObra={
          shell != null && typeof shell.showEditarObra === 'boolean' ? shell.showEditarObra : false
        }
      />

      {data.etapas.length === 0 ? (
        <label className="col-xs-12 no-padding cards-empty-label">Nenhum registro encontrado.</label>
      ) : (
        <>
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

          <div className="lista-tarefas">
            <div className="panel-group accordion" id="accordion">
              {data.etapas.map((etapa: EtapaComTarefas) => {
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
                                <TaskCardAgrupador key={t.id} tarefa={t} etapaId={etapa.id} />
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
    </section>,
  )
}
