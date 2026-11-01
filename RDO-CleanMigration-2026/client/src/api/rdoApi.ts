import type {
  RdoCadastroBootstrap,
  RdoCadastroEtapas,
  RdoCadastroSaveRequest,
  RdoCadastroSaveResult,
  RdoListPage,
  RdoStatusOption,
} from './equipamentos-api.types'

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
      /* HTML ou texto puro */
    }
    const short =
      fromJson?.trim() ||
      (text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor (${fallback}).`
        : text.slice(0, 400) || `Erro ${res.status} (${fallback}).`)
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

export async function fetchRdoCadastroBootstrap(): Promise<RdoCadastroBootstrap> {
  const res = await fetch('/api/bff/rdos/cadastro/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap cadastro RDO')
}

export async function fetchRdoCadastroEtapas(dataRdo: string): Promise<RdoCadastroEtapas> {
  const params = new URLSearchParams({ dataRdo: dataRdo.trim() })
  const res = await fetch(`/api/bff/rdos/cadastro/etapas?${params}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'etapas cadastro RDO')
}

export async function saveRdoCadastro(body: RdoCadastroSaveRequest): Promise<RdoCadastroSaveResult> {
  const res = await fetch('/api/bff/rdos/cadastro', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  const text = await res.text()
  let data: RdoCadastroSaveResult
  try {
    data = JSON.parse(text) as RdoCadastroSaveResult
  } catch {
    const short =
      text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor (salvar RDO). Abra a aba Resposta no F12 ou redeploy Core.`
        : text.slice(0, 500) || `Erro ${res.status} ao salvar RDO.`
    throw new Error(short)
  }
  if (!res.ok && !data.needsConfirm) {
    throw new Error(data.errorMessage ?? `Erro ${res.status} ao salvar RDO.`)
  }
  return data
}

export async function downloadRdoPdf(
  idRdo: number,
  dataRdoLabel: string,
  gerarRelatorioFotografico = false,
): Promise<void> {
  const res = await fetch(`/api/bff/rdos/${idRdo}/pdf`, {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/pdf', 'Content-Type': 'application/json' },
    body: JSON.stringify({ idRdo, gerarRelatorioFotografico }),
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
      /* keep text */
    }
    const short =
      message.includes('<!DOCTYPE') || message.includes('<html')
        ? `Erro ${res.status} ao gerar PDF (página HTML de erro). Request ID no F12; redeploy L6.`
        : message
    throw new Error(short || `Erro ${res.status} ao gerar PDF.`)
  }
  const blob = await res.blob()
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `RDO_${dataRdoLabel.replace(/\//g, '_')}.pdf`
  link.rel = 'noopener'
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}
