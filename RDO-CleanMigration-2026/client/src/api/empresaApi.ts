export type EmpresaIndexLookup = { id: number; nome: string }

export type EmpresaIndexPermissions = {
  showVisualizar: boolean
}

export type EmpresaIndexBootstrap = {
  obraNomeSessao: string
  ufs: EmpresaIndexLookup[]
  ramos: EmpresaIndexLookup[]
  setores: EmpresaIndexLookup[]
  permissions: EmpresaIndexPermissions
}

export type EmpresaIndexFilter = {
  razaoSocial: string
  cnpj: string
  idUf: number
  idMunicipio: number
  idRamo: number
  idSetor: number
}

export type EmpresaIndexItem = {
  idEmpresa: number
  razaoSocial: string
  nomeFantasia: string
  local: string
  telefone: string
  editavel: boolean
}

export type EmpresaIndexListResponse = {
  obraNomeSessao: string
  items: EmpresaIndexItem[]
}

async function readJson<T>(res: Response, label: string): Promise<T> {
  if (!res.ok) {
    let message = `${label}: HTTP ${res.status}`
    try {
      const body = (await res.json()) as { message?: string; errorMessage?: string }
      message = body.message || body.errorMessage || message
    } catch {
      /* ignore */
    }
    throw new Error(message)
  }
  return res.json() as Promise<T>
}

export async function fetchEmpresaIndexBootstrap(): Promise<EmpresaIndexBootstrap> {
  const res = await fetch('/api/bff/empresas/index/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap empresas')
}

export async function fetchEmpresaIndexMunicipios(idUf: number): Promise<EmpresaIndexLookup[]> {
  const res = await fetch(`/api/bff/empresas/index/municipios?idUf=${idUf}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'municípios')
}

export async function fetchEmpresaIndexLista(filtro: EmpresaIndexFilter): Promise<EmpresaIndexListResponse> {
  const q = new URLSearchParams()
  if (filtro.razaoSocial.trim()) q.set('razaoSocial', filtro.razaoSocial.trim())
  if (filtro.cnpj.trim()) q.set('cnpj', filtro.cnpj.trim())
  if (filtro.idUf > 0) q.set('idUf', String(filtro.idUf))
  if (filtro.idMunicipio > 0) q.set('idMunicipio', String(filtro.idMunicipio))
  if (filtro.idRamo > 0) q.set('idRamo', String(filtro.idRamo))
  if (filtro.idSetor > 0) q.set('idSetor', String(filtro.idSetor))
  const qs = q.toString()
  const res = await fetch(`/api/bff/empresas/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista empresas')
}

/** Máscara telefone BR simples (paridade visual EmpresaController.maskPhone). */
export function maskPhone(raw: string | null | undefined): string {
  const d = (raw ?? '').replace(/\D/g, '')
  if (d.length === 11) {
    return `(${d.slice(0, 2)}) ${d.slice(2, 7)}-${d.slice(7)}`
  }
  if (d.length === 10) {
    return `(${d.slice(0, 2)}) ${d.slice(2, 6)}-${d.slice(6)}`
  }
  return raw?.trim() || ''
}
