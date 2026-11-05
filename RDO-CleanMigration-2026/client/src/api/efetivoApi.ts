export type EfetivoLookup = {
  id: number
  nome: string
  cor?: string | null
}

export type EfetivoItem = {
  idEfetivo: number
  idObraColaborador: number
  data: string
  nomeColaborador: string
  cargo: string
  idStatus: number
  nomeStatus: string
  cor?: string | null
}

export type EfetivoBootstrap = {
  dataPadrao: string
  obraNome: string
  cargos: EfetivoLookup[]
  statuses: EfetivoLookup[]
}

export type EfetivoList = {
  items: EfetivoItem[]
}

export type EfetivoStatusUpdateResult = {
  ok: boolean
  idEfetivo?: number | null
  errorMessage?: string | null
}

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let fromJson: string | undefined
    try {
      const j = JSON.parse(text) as { message?: string; errorMessage?: string }
      fromJson = j.message || j.errorMessage
    } catch {
      /* */
    }
    throw new Error(fromJson?.trim() || text.slice(0, 400) || `Erro ${res.status} (${fallback}).`)
  }
  return res.json() as Promise<T>
}

export async function fetchEfetivoBootstrap(): Promise<EfetivoBootstrap> {
  const res = await fetch('/api/bff/efetivo/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap efetivo')
}

export async function fetchEfetivoList(params: {
  data: string
  nome?: string
  cargoId?: number
  statusId?: number
}): Promise<EfetivoList> {
  const q = new URLSearchParams()
  q.set('data', params.data)
  if (params.nome?.trim()) q.set('nome', params.nome.trim())
  if (params.cargoId && params.cargoId > 0) q.set('cargoId', String(params.cargoId))
  if (params.statusId && params.statusId > 0) q.set('statusId', String(params.statusId))
  const res = await fetch(`/api/bff/efetivo?${q}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista efetivo')
}

export async function updateEfetivoStatus(body: {
  idEfetivo: number
  idObraColaborador: number
  idStatus: number
  data: string
}): Promise<EfetivoStatusUpdateResult> {
  const res = await fetch('/api/bff/efetivo/status', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'status efetivo')
}
