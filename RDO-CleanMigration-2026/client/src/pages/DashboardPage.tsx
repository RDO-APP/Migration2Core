import { useEffect, useMemo, useState } from 'react'
import { fetchDashboardObra } from '../api/graficoApi'
import type { DashboardObra, DashboardSlice } from '../api/equipamentos-api.types'
import {
  buildPieChartSvg,
  buildSimpleBarSvg,
  pieSlicePath,
  type PieSlice,
} from '../chart/chartExport'
import { ChartExportMenu } from '../components/ChartExportMenu'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

type DashTab = 'pie' | 'column' | 'efetivo'

const PIE_COLORS = ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f']

const STATUS_COLORS: Record<string, string> = {
  'Em Execução': '#51BCDC',
  Planejada: '#999999',
  Cancelada: '#D04541',
  Pausada: '#FF8000',
  Finalizada: '#57B257',
}

type Tip = { x: number; y: number; lines: string[] }

function readTab(): DashTab {
  const h = (window.location.hash || '').replace('#', '').toLowerCase()
  if (h === 'column' || h === 'efetivo' || h === 'pie') return h
  return 'pie'
}

function setTabHash(tab: DashTab) {
  window.history.replaceState({}, '', `${window.location.pathname}${window.location.search}#${tab}`)
}

function toPieSlices(slices: DashboardSlice[]): PieSlice[] {
  return slices.map((s, i) => ({
    name: s.name,
    y: s.y || 0,
    color: PIE_COLORS[i % PIE_COLORS.length],
  }))
}

function pct(value: number, total: number): string {
  if (total <= 0) return '0.0'
  return ((value / total) * 100).toFixed(1)
}

function PieChart({
  title,
  slices,
  exportName,
}: {
  title: string
  slices: DashboardSlice[]
  exportName: string
}) {
  const data = useMemo(() => toPieSlices(slices), [slices])
  const total = useMemo(() => data.reduce((s, x) => s + x.y, 0), [data])
  const [tip, setTip] = useState<Tip | null>(null)
  const size = 320
  const cx = size / 2
  const cy = size / 2
  const r = 130

  let angle = 0
  const arcs =
    total <= 0
      ? null
      : data.map((s) => {
          const start = angle
          const sweep = (s.y / total) * 360
          angle += sweep
          const end = angle
          const path = pieSlicePath(cx, cy, r, start, end)
          return { ...s, path, start, end }
        })

  return (
    <div className="dashboard-chart-card">
      <div className="chart-panel-head">
        <h4>{title}</h4>
        <ChartExportMenu filename={exportName} getSvg={() => buildPieChartSvg(title, data)} />
      </div>
      {data.length === 0 || total <= 0 ? (
        <p className="dashboard-empty">Sem dados para exibir.</p>
      ) : (
        <div className="dashboard-chart-body">
          <div
            className="dashboard-pie-host"
            onMouseLeave={() => setTip(null)}
          >
            <svg viewBox={`0 0 ${size} ${size}`} className="dashboard-pie-svg" role="img" aria-label={title}>
              {arcs?.map((a) => (
                <path
                  key={a.name}
                  d={a.path}
                  fill={a.color}
                  stroke="#fff"
                  strokeWidth={1}
                  style={{ cursor: 'pointer' }}
                  onMouseMove={(e) => {
                    const host = e.currentTarget.ownerSVGElement?.parentElement
                    if (!host) return
                    const rect = host.getBoundingClientRect()
                    setTip({
                      x: e.clientX - rect.left + 12,
                      y: e.clientY - rect.top + 12,
                      lines: [`${a.name}: ${a.y}`, `Percentual: ${pct(a.y, total)}%`],
                    })
                  }}
                />
              ))}
            </svg>
            {tip ? (
              <div className="dashboard-tooltip" style={{ left: tip.x, top: tip.y }}>
                {tip.lines.map((line) => (
                  <div key={line}>{line}</div>
                ))}
              </div>
            ) : null}
          </div>
          <ul className="dashboard-legend">
            {data.map((s) => (
              <li key={s.name}>
                <span className="dashboard-swatch" style={{ background: s.color }} />
                <span className="dashboard-legend-name">
                  {s.name}: {s.y}
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

function StatusBarChart({
  title,
  categorias,
  valores,
}: {
  title: string
  categorias: string[]
  valores: number[]
}) {
  const items = useMemo(
    () =>
      categorias.map((label, i) => ({
        label,
        value: valores[i] ?? 0,
        color: STATUS_COLORS[label] ?? '#28496f',
      })),
    [categorias, valores],
  )
  const max = Math.max(1, ...items.map((i) => i.value))
  const [tip, setTip] = useState<Tip | null>(null)

  return (
    <div className="dashboard-chart-card">
      <div className="chart-panel-head">
        <h4>{title}</h4>
        <ChartExportMenu filename="tarefas-por-status" getSvg={() => buildSimpleBarSvg(title, items)} />
      </div>
      <div className="dashboard-chart-body dashboard-bar-host" onMouseLeave={() => setTip(null)}>
        <div className="chart-bars dashboard-status-bars">
          {items.map((item) => (
            <div
              key={item.label}
              className="chart-bar-row"
              onMouseMove={(e) => {
                const host = e.currentTarget.closest('.dashboard-bar-host') as HTMLElement | null
                if (!host) return
                const rect = host.getBoundingClientRect()
                setTip({
                  x: e.clientX - rect.left + 12,
                  y: e.clientY - rect.top + 12,
                  lines: [`${item.label}: ${item.value}`, 'Tarefas'],
                })
              }}
            >
              <span>{item.label}</span>
              <div className="chart-bar-track">
                <div
                  className="chart-bar-fill"
                  style={{
                    width: `${(item.value / max) * 100}%`,
                    background: item.color,
                  }}
                />
              </div>
              <span>{item.value}</span>
            </div>
          ))}
        </div>
        {tip ? (
          <div className="dashboard-tooltip" style={{ left: tip.x, top: tip.y }}>
            {tip.lines.map((line) => (
              <div key={line}>{line}</div>
            ))}
          </div>
        ) : null}
      </div>
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
                  <PieChart
                    title="Colaboradores por cargo"
                    slices={data.pizzaColaboradores}
                    exportName="colaboradores-por-cargo"
                  />
                ) : null}
                {tab === 'column' ? (
                  <StatusBarChart
                    title="Tarefas por status"
                    categorias={data.barraCategorias}
                    valores={data.barraValores}
                  />
                ) : null}
                {tab === 'efetivo' ? (
                  <PieChart
                    title="Efetivo diário nos ultimos 30 dias"
                    slices={data.pizzaEfetivo}
                    exportName="efetivo-30-dias"
                  />
                ) : null}
              </div>
            </div>

            <div className="dashboard-report-actions">
              <a className="dashboard-report-btn" href="/relatoriomedicao/index">
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de medição
              </a>
              <a className="dashboard-report-btn" href="/relatorioprodutividade/index">
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de produtividade
              </a>
              <a className="dashboard-report-btn" href="/relatorioefetivodiario/index">
                <span className="dashboard-report-ico" aria-hidden />
                Relatório de efetivo diário
              </a>
            </div>
          </>
        ) : null}
      </div>
    </OperadorShell>
  )
}
