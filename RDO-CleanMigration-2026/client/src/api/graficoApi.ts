import type { DashboardObra, GraficoResumo } from './equipamentos-api.types'

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let fromJson: string | undefined
    try {
      const j = JSON.parse(text) as { message?: string }
      fromJson = j.message
    } catch {
      /* HTML */
    }
    throw new Error(fromJson?.trim() || `Erro ${res.status} (${fallback}).`)
  }
  return res.json() as Promise<T>
}

export async function fetchGraficoResumo(periodoIni: string, periodoFim: string): Promise<GraficoResumo> {
  const q = new URLSearchParams({ periodoIni, periodoFim })
  const res = await fetch(`/api/bff/grafico/resumo?${q}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'gráfico')
}

export async function fetchDashboardObra(): Promise<DashboardObra> {
  const res = await fetch('/api/bff/dashboard', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'dashboard')
}
