import type { RdoListPage, RdoStatusOption } from './equipamentos-api.types'

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    const short =
      text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor (${fallback}).`
        : text || `Erro ${res.status} (${fallback}).`
    throw new Error(short)
  }
  return res.json() as Promise<T>
}

export async function fetchRdoStatusOptions(): Promise<RdoStatusOption[]> {
  const res = await fetch('/api/bff/rdos/status-options', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'status RDO')
}

export type RdoListQuery = {
  page?: number
  statusRdo?: number
  dataInicial?: string
  dataFinal?: string
}

export async function fetchRdoList(query: RdoListQuery = {}): Promise<RdoListPage> {
  const params = new URLSearchParams()
  if (query.page != null) params.set('page', String(query.page))
  if (query.statusRdo != null) params.set('statusRdo', String(query.statusRdo))
  if (query.dataInicial?.trim()) params.set('dataInicial', query.dataInicial.trim())
  if (query.dataFinal?.trim()) params.set('dataFinal', query.dataFinal.trim())

  const qs = params.toString()
  const res = await fetch(`/api/bff/rdos${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista RDO')
}
