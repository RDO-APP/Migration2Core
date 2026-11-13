import { useEffect, useMemo, useState } from 'react'
import { fetchDashboardObra } from '../api/graficoApi'
import type { DashboardObra, DashboardSlice } from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

type DashTab = 'pie' | 'column' | 'efetivo'

const PIE_COLORS = ['#254B59', '#2E7D32', '#F57C00', '#1565C0', '#8E24AA', '#C2185B', '#00838F', '#6D4C41']

const STATUS_COLORS: Record<string, string> = {
  'Em Execução': '#51BCDC',
  Planejada: '#999999',
  Cancelada: '#D04541',
  Pausada: '#FF8000',
  Finalizada: '#57B257',
}

function maxVal(nums: number[]): number {
  return Math.max(1, ...nums)
}

function readTab(): DashTab {
  const h = (window.location.hash || '').replace('#', '').toLowerCase()
  if (h === 'column' || h === 'efetivo' || h === 'pie') return h
  return 'pie'
}

function setTabHash(tab: DashTab) {
  const url = `${window.location.pathname}${window.location.search}#${tab}`
  window.history.replaceState({}, '', url)
}

function pieConic(slices: DashboardSlice[], colors: string[]): string {
  const total = slices.reduce((s, x) => s + (x.y || 0), 0)
  if (total <= 0) return 'conic-gradient(#e0e0e0 0 100%)'
  let acc = 0
  const parts: string[] = []
  slices.forEach((s, i) => {
    const start = (acc / total) * 100
    acc += s.y || 0
    const end = (acc / total) * 100
    const color = colors[i % colors.length]
    parts.push(`${color} ${start}% ${end}%`)
  })
  return `conic-gradient(${parts.join(', ')})`
}

function PiePanel({ title, slices }: { title: string; slices: DashboardSlice[] }) {
  const style = useMemo(() => ({ background: pieConic(slices, PIE_COLORS) }), [slices])
  return (
    <div className="dashboard-chart-wrap">
      <h4 className="dashboard-chart-title">{title}</h4>
      {slices.length === 0 ? (
        <p className="dashboard-empty">Sem dados para exibir.</p>
      ) : (
        <>
          <div className="dashboard-pie" style={style} aria-hidden />
          <ul className="dashboard-legend">
            {slices.map((s, i) => (
              <li key={s.name}>
                <span className="dashboard-swatch" style={{ background: PIE_COLORS[i % PIE_COLORS.length] }} />
                <span className="dashboard-legend-name">{s.name}</span>
                <strong>{s.y}</strong>
              </li>
            ))}
          </ul>
        </>
      )}
    </div>
  )
}

export function DashboardPage() {
  const { shell } = useShellContext()
  const [data, setData] = useState<DashboardObra | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<DashTab>(() => readTab())

  useEffect(() => {
    void (async () => {
      try {
        setData(await fetchDashboardObra())
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : 'Falha ao carregar dashboard.'
        setError(msg)
        showToast('error', msg)
      }
    })()
  }, [])

  useEffect(() => {
    const onHash = () => setTab(readTab())
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  const selectTab = (next: DashTab) => {
    setTab(next)
    setTabHash(next)
  }

  const barraMax = data ? maxVal(data.barraValores) : 1

  return (
    <OperadorShell variant="dashboard" shell={shell}>
      <div className="dashboard-page">
        <div className="panel-heading">
          <h3>DashBoards</h3>
        </div>
        {error ? <p className="text-danger">{error}</p> : null}
        {!data && !error ? <p>Carregando…</p> : null}
        {data ? (
          <>
            <div className="dashboard-guias">
              <div className="dashboard-tabs" role="tablist">
                <button
                  type="button"
                  role="tab"
                  aria-selected={tab === 'pie'}
                  className={tab === 'pie' ? 'active' : undefined}
                  onClick={() => selectTab('pie')}
                >
                  Gráfico de Colaboradores
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={tab === 'column'}
                  className={tab === 'column' ? 'active' : undefined}
                  onClick={() => selectTab('column')}
                >
                  Gráfico de Tarefas
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={tab === 'efetivo'}
                  className={tab === 'efetivo' ? 'active' : undefined}
                  onClick={() => selectTab('efetivo')}
                >
                  Gráfico de Efetivo
                </button>
              </div>

              <div className="dashboard-tab-panel chart-panel">
                {tab === 'pie' ? (
                  <PiePanel title="Colaboradores por cargo" slices={data.pizzaColaboradores} />
                ) : null}
                {tab === 'column' ? (
                  <div className="dashboard-chart-wrap">
                    <h4 className="dashboard-chart-title">Tarefas por status</h4>
                    <div className="chart-bars dashboard-status-bars">
                      {data.barraCategorias.map((cat, i) => {
                        const val = data.barraValores[i] ?? 0
                        const color = STATUS_COLORS[cat] ?? '#28496f'
                        return (
                          <div key={cat} className="chart-bar-row">
                            <span>{cat}</span>
                            <div className="chart-bar-track">
                              <div
                                className="chart-bar-fill"
                                style={{
                                  width: `${(val / barraMax) * 100}%`,
                                  background: color,
                                }}
                              />
                            </div>
                            <span>{val}</span>
                          </div>
                        )
                      })}
                    </div>
                  </div>
                ) : null}
                {tab === 'efetivo' ? (
                  <PiePanel title="Efetivo (30 dias)" slices={data.pizzaEfetivo} />
                ) : null}
              </div>
            </div>

            <div className="dashboard-report-actions">
              <button
                type="button"
                className="dashboard-report-btn"
                onClick={() => goOperador('/relatoriomedicao/index')}
              >
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de medição
              </button>
              <button
                type="button"
                className="dashboard-report-btn"
                onClick={() => goOperador('/relatorioprodutividade/index')}
              >
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de produtividade
              </button>
              <button
                type="button"
                className="dashboard-report-btn"
                onClick={() => goOperador('/relatorioefetivodiario/index')}
              >
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de efetivo diário
              </button>
            </div>
          </>
        ) : null}
      </div>
    </OperadorShell>
  )
}
