import { useEffect, useState } from 'react'
import { fetchDashboardObra } from '../api/graficoApi'
import type { DashboardObra } from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

function maxVal(nums: number[]): number {
  return Math.max(1, ...nums)
}

export function DashboardPage() {
  const { shell } = useShellContext()
  const [data, setData] = useState<DashboardObra | null>(null)
  const [error, setError] = useState<string | null>(null)

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

  const barraMax = data ? maxVal(data.barraValores) : 1

  return (
    <OperadorShell variant="dashboard" shell={shell}>
      <div className="dashboard-page">
        <div className="panel-heading">
          <h3>Dashboard da obra</h3>
        </div>
        {error ? <p className="text-danger">{error}</p> : null}
        {!data && !error ? <p>Carregando…</p> : null}
        {data ? (
          <>
            <div className="chart-panel">
              <h4>Colaboradores por cargo</h4>
              {data.pizzaColaboradores.length === 0 ? (
                <p className="dashboard-slice">Nenhum colaborador nesta obra.</p>
              ) : (
                data.pizzaColaboradores.map((s) => (
                  <div key={s.name} className="dashboard-slice">
                    <span>{s.name}</span>
                    <strong>{s.y}</strong>
                  </div>
                ))
              )}
            </div>
            <div className="chart-panel">
              <h4>Tarefas por status</h4>
              <div className="chart-bars">
                {data.barraCategorias.map((cat, i) => (
                  <div key={cat} className="chart-bar-row">
                    <span>{cat}</span>
                    <div className="chart-bar-track">
                      <div className="chart-bar-fill" style={{ width: `${((data.barraValores[i] ?? 0) / barraMax) * 100}%` }} />
                    </div>
                    <span>{data.barraValores[i] ?? 0}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="chart-panel">
              <h4>Efetivo (30 dias)</h4>
              {data.pizzaEfetivo.length === 0 ? (
                <p className="dashboard-slice">Sem lançamentos de efetivo no período.</p>
              ) : (
                data.pizzaEfetivo.map((s) => (
                  <div key={s.name} className="dashboard-slice">
                    <span>{s.name}</span>
                    <strong>{s.y}</strong>
                  </div>
                ))
              )}
            </div>
          </>
        ) : null}
      </div>
    </OperadorShell>
  )
}
