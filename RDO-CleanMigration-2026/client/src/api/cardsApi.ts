import type { CardsContext } from './equipamentos-api.types'

export async function fetchCardsContext(): Promise<CardsContext> {
  const res = await fetch('/api/bff/etapas', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })

  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }

  if (!res.ok) {
    const text = await res.text()
    throw new Error(text || `Erro ${res.status} ao carregar tarefas.`)
  }

  return res.json() as Promise<CardsContext>
}
