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
    let message = `Erro ${res.status} ao carregar obras.`
    if (text.trimStart().startsWith('{')) {
      try {
        const body = JSON.parse(text) as { message?: string }
        if (body.message) message = body.message
      } catch {
        /* keep default */
      }
    } else if (text.includes('<html') || text.includes('<!DOCTYPE')) {
      message = 'Falha no servidor ao listar obras. Tente login novamente ou contate o suporte.'
    } else if (text.trim()) {
      message = text.length > 280 ? `${text.slice(0, 280)}…` : text
    }
    throw new Error(message)
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
