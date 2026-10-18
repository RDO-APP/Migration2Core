import { useEffect, useState } from 'react'
import { fetchCardsContext } from './api/cardsApi'
import type { CardsContext } from './api/equipamentos-api.types'
import './App.css'

function App() {
  const [data, setData] = useState<CardsContext | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    fetchCardsContext()
      .then((ctx) => {
        if (!cancelled) setData(ctx)
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

  if (loading) {
    return (
      <main className="cards-page">
        <p className="muted">Carregando tarefas…</p>
      </main>
    )
  }

  if (error) {
    return (
      <main className="cards-page">
        <h1>Tarefas</h1>
        <p className="error">{error}</p>
        <p>
          <a href="/Obra/Escolher">Escolher obra</a>
        </p>
      </main>
    )
  }

  if (!data) {
    return null
  }

  const totalTarefas = data.etapas.reduce((n, e) => n + e.tarefas.length, 0)

  return (
    <main className="cards-page">
      <header className="cards-header">
        <h1>Tarefas</h1>
        <p className="muted">
          Obra: <strong>{data.obraNome}</strong> · {data.etapas.length} etapa(s) ·{' '}
          {totalTarefas} tarefa(s)
        </p>
      </header>

      {data.etapas.length === 0 ? (
        <p className="muted">Nenhuma etapa cadastrada para esta obra.</p>
      ) : (
        <ul className="etapa-list">
          {data.etapas.map((etapa) => (
            <li key={etapa.id} className="etapa-block">
              <h2>
                <span className="etapa-ordem">{etapa.ordem}.</span> {etapa.titulo}
              </h2>
              {etapa.tarefas.length === 0 ? (
                <p className="muted small">Sem tarefas nesta etapa.</p>
              ) : (
                <ul className="tarefa-list">
                  {etapa.tarefas.map((t) => (
                    <li key={t.id} className="tarefa-item">
                      <span className="tarefa-desc">{t.descricao}</span>
                      {t.nomeStatus ? (
                        <span className="tarefa-status">{t.nomeStatus}</span>
                      ) : null}
                    </li>
                  ))}
                </ul>
              )}
            </li>
          ))}
        </ul>
      )}

      <footer className="cards-footer muted small">
        RDO App Equipamentos · EQ-R M2
      </footer>
    </main>
  )
}

export default App
