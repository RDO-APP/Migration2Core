import type { EscolherContext, SelecionarObraResponse } from './equipamentos-api.types'

export async function fetchEscolherContext(): Promise<EscolherContext> {
  const res = await fetch('/api/bff/obras', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })

  if (res.status === 401) {
    throw new Error('Sessão expirada. Faça login novamente.')
  }

  if (!res.ok) {
    const text = await res.text()
    throw new Error(text || `Erro ${res.status} ao carregar obras.`)
  }

  return res.json() as Promise<EscolherContext>
}

export async function selecionarObra(idObra: number): Promise<SelecionarObraResponse> {
  const res = await fetch('/api/bff/obras/selecionar', {
    method: 'POST',
    credentials: 'include',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ idObra }),
  })

  const data = (await res.json()) as SelecionarObraResponse
  if (!res.ok || !data.success) {
    throw new Error(data.errorMessage ?? `Erro ${res.status} ao selecionar obra.`)
  }

  return data
}
