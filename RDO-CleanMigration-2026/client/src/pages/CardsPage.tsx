import { useEffect, useMemo, useState } from 'react'
import { fetchCardsContext } from '../api/cardsApi'
import type { EtapaComTarefas, TarefaCard } from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import '../App.css'

function formatDateBr(iso?: string): string {
  if (!iso) return '—'
  const part = iso.slice(0, 10)
  const [y, m, d] = part.split('-')
  if (!y || !m || !d) return iso
  return `${d}/${m}/${y}`
}

function TaskCard({ tarefa }: { tarefa: TarefaCard }) {
  const pct = Math.min(100, Math.max(0, tarefa.percentualConcluido ?? 0))
  const headClass = tarefa.classeStatusCss?.trim() || 'bg-cinza'
  const extrapolado = tarefa.percentualExtrapolado === 'false'
  const inicio = formatDateBr(tarefa.dataInicio)
  const fim = formatDateBr(tarefa.dataPrevisaoFim)
  const hasDates = Boolean(tarefa.dataInicio || tarefa.dataPrevisaoFim)

  return (
    <article className="task-card">
      <div className={`task-card-head ${headClass}`}>
        <h5 className="task-card-title">{tarefa.descricao}</h5>
      </div>
      {hasDates ? (
        <div className="task-card-datas">
          <span className="task-card-datas-label">Planejada</span>
          <span>
            {inicio} à {fim}
          </span>
        </div>
      ) : null}
      <div className="task-card-progress">
        {extrapolado ? (
          <span className="task-card-warn" title="Percentual acima de 100%">
            ⚠
          </span>
        ) : null}
        <div
          className="task-card-progress-track"
          role="progressbar"
          aria-valuenow={pct}
          aria-valuemin={0}
          aria-valuemax={100}
        >
          <div className="task-card-progress-fill" style={{ width: `${pct}%` }} />
        </div>
        <span className="task-card-pct">{pct}%</span>
      </div>
      {tarefa.nomeStatus ? (
        <div className="task-card-status-row">
          <span className="task-card-status">{tarefa.nomeStatus}</span>
        </div>
      ) : null}
    </article>
  )
}

export function CardsPage() {
  const [data, setData] = useState<Awaited<ReturnType<typeof fetchCardsContext>> | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [openEtapas, setOpenEtapas] = useState<Set<number>>(() => new Set())

  useEffect(() => {
    let cancelled = false
    fetchCardsContext()
      .then((ctx) => {
        if (!cancelled) {
          setData(ctx)
          const first = ctx.etapas[0]?.id
          if (first != null) {
            setOpenEtapas(new Set([first]))
          }
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

  const totalTarefas = useMemo(
    () => data?.etapas.reduce((n, e) => n + e.tarefas.length, 0) ?? 0,
    [data],
  )

  function toggleEtapa(id: number) {
    setOpenEtapas((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  if (loading) {
    return (
      <OperadorShell>
        <div className="cards-page">
          <p className="muted cards-loading">Carregando tarefas…</p>
        </div>
      </OperadorShell>
    )
  }

  if (error) {
    return (
      <OperadorShell>
        <div className="cards-page">
          <p className="error">{error}</p>
          <p>
            <a href="/Obra/Escolher">Escolher obra</a>
          </p>
        </div>
      </OperadorShell>
    )
  }

  if (!data) {
    return null
  }

  return (
    <OperadorShell obraNome={data.obraNome} usuarioNome={data.usuarioNome}>
      <div className="cards-page">
        <header className="cards-subheader">
          <p className="cards-meta muted">
            {data.etapas.length} etapa(s) · {totalTarefas} tarefa(s) · EQ-R M4
          </p>
        </header>

        {data.etapas.length === 0 ? (
          <p className="muted cards-empty">Nenhum registro encontrado.</p>
        ) : (
          <div className="etapa-accordion" role="presentation">
            {data.etapas.map((etapa: EtapaComTarefas) => {
              const open = openEtapas.has(etapa.id)
              return (
                <section key={etapa.id} className={`etapa-panel ${open ? 'is-open' : ''}`}>
                  <button
                    type="button"
                    className="etapa-panel-heading"
                    aria-expanded={open}
                    onClick={() => toggleEtapa(etapa.id)}
                  >
                    <span className="etapa-panel-title">{etapa.titulo}</span>
                    <span className="etapa-panel-chevron" aria-hidden>
                      {open ? '▾' : '▸'}
                    </span>
                  </button>
                  {open ? (
                    <div className="etapa-panel-body">
                      {etapa.tarefas.length === 0 ? (
                        <p className="muted small etapa-empty">Nenhuma tarefa adicionada nesta etapa.</p>
                      ) : (
                        <div className="task-card-grid">
                          {etapa.tarefas.map((t) => (
                            <TaskCard key={t.id} tarefa={t} />
                          ))}
                        </div>
                      )}
                    </div>
                  ) : null}
                </section>
              )
            })}
          </div>
        )}
      </div>
    </OperadorShell>
  )
}
