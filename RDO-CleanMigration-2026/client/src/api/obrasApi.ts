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

export type ObraIndexLookup = { id: number; nome: string }

export type ObraIndexPermissions = {
  showVisualizar: boolean
  showEnviarConvite: boolean
  showCopiar: boolean
  showEditar: boolean
  showDeletar: boolean
  showCriarNovo: boolean
}

export type ObraIndexBootstrap = {
  obraNomeSessao: string
  empresas: ObraIndexLookup[]
  ufs: ObraIndexLookup[]
  permissions: ObraIndexPermissions
}

export type ObraIndexFilter = {
  descricao: string
  idContratante: number
  dataInicioDe: string
  dataInicioAte: string
  idUf: number
  idMunicipio: number
  statusObra: number
}

export type ObraIndexItem = {
  idObra: number
  descricao: string
  descricaoContratante: string
  descricaoContratada: string
  dataInicio: string
  dataConclusao: string
  cidadeEstado: string
  diasDecorridos: number
}

export type ObraIndexListResponse = {
  obraNomeSessao: string
  items: ObraIndexItem[]
}

export type ObraIndexActionResult = {
  ok: boolean
  errorMessage?: string
}

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada. Faça login novamente.')
  }
  if (res.status === 403) {
    throw new Error('Sem permissão para esta ação.')
  }
  if (!res.ok) {
    const text = await res.text()
    let message = `Erro ${res.status} (${fallback}).`
    if (text.trimStart().startsWith('{')) {
      try {
        const body = JSON.parse(text) as { message?: string; errorMessage?: string }
        message = body.message || body.errorMessage || message
      } catch {
        /* */
      }
    }
    throw new Error(message)
  }
  return res.json() as Promise<T>
}

export async function fetchObraIndexBootstrap(): Promise<ObraIndexBootstrap> {
  const res = await fetch('/api/bff/obras/index/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap obras')
}

export async function fetchObraIndexMunicipios(idUf: number): Promise<ObraIndexLookup[]> {
  const res = await fetch(`/api/bff/obras/index/municipios?idUf=${idUf}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'municípios')
}

export async function fetchObraIndexLista(filtro: ObraIndexFilter): Promise<ObraIndexListResponse> {
  const q = new URLSearchParams()
  if (filtro.descricao.trim()) q.set('descricao', filtro.descricao.trim())
  if (filtro.idContratante > 0) q.set('idContratante', String(filtro.idContratante))
  if (filtro.dataInicioDe.trim()) q.set('dataInicioDe', filtro.dataInicioDe.trim())
  if (filtro.dataInicioAte.trim()) q.set('dataInicioAte', filtro.dataInicioAte.trim())
  if (filtro.idUf > 0) q.set('idUf', String(filtro.idUf))
  if (filtro.idMunicipio > 0) q.set('idMunicipio', String(filtro.idMunicipio))
  if (filtro.statusObra > 0) q.set('statusObra', String(filtro.statusObra))
  const qs = q.toString()
  const res = await fetch(`/api/bff/obras/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista obras')
}

export async function deleteObraIndex(idObra: number): Promise<ObraIndexActionResult> {
  const res = await fetch(`/api/bff/obras/${idObra}`, {
    method: 'DELETE',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'excluir obra')
}

export async function enviarConviteObra(idObra: number, emailConvidada: string): Promise<ObraIndexActionResult> {
  const res = await fetch('/api/bff/obras/convidar', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ idObra, emailConvidada }),
  })
  return readJson(res, 'enviar convite')
}
