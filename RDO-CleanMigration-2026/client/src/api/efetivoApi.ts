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

export type EfetivoCopiarResult = {
  ok: boolean
  copiados?: number
  errorMessage?: string | null
}

/** Paridade prod POST api/efetivo/CopiarEfetivo */
export async function copiarEfetivo(body: {
  dataOrigem: string
  dataDestino: string
}): Promise<EfetivoCopiarResult> {
  const res = await fetch('/api/bff/efetivo/copiar', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'copiar efetivo')
}

function triggerDownload(blob: Blob, fileName: string) {
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  link.rel = 'noopener'
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}

/** Paridade prod POST api/efetivo/gerarrelatorio + Download.base64 */
export async function downloadEfetivoRelatorio(body: {
  dataInicial: string
  dataFinal: string
  tipoRelatorio: 'PDF' | 'Excel'
}): Promise<void> {
  const res = await fetch('/api/bff/efetivo/relatorio', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: '*/*', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let message = text
    try {
      const j = JSON.parse(text) as { message?: string }
      message = j.message ?? text
    } catch {
      /* keep */
    }
    throw new Error(message || `Erro ${res.status} ao gerar relatório.`)
  }
  const blob = await res.blob()
  const cd = res.headers.get('Content-Disposition') ?? ''
  const match = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/.exec(cd)
  let fileName =
    body.tipoRelatorio === 'Excel'
      ? `EfetivoDiario_${body.dataInicial}_${body.dataFinal}.xls`
      : `EfetivoDiario_${body.dataInicial}_${body.dataFinal}.pdf`
  if (match?.[1]) {
    fileName = match[1].replace(/['"]/g, '').trim()
  }
  triggerDownload(blob, fileName)
}
