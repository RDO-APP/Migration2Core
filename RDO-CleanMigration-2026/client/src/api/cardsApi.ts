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
    const short =
      text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor ao carregar tarefas (homolog).`
        : text || `Erro ${res.status} ao carregar tarefas.`
    throw new Error(short)
  }

  return res.json() as Promise<CardsContext>
}
