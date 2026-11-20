export type ConvidadaLookup = { id: number; nome: string }

export type ConvidadaBootstrap = {
  ok: boolean
  errorMessage?: string | null
  codigoConvite: string
  idObra: number
  nomeObra: string
  papel: string
  tipoConvite: number
  ufs: ConvidadaLookup[]
  setores: ConvidadaLookup[]
  ramos: ConvidadaLookup[]
  cargos: ConvidadaLookup[]
}

export type ConvidadaEmpresaHint = {
  found: boolean
  cnpj?: string | null
  razaoSocial?: string | null
  nomeFantasia?: string | null
  idSetor?: number | null
  idRamo?: number | null
}

export type ConvidadaColaboradorHint = {
  found: boolean
  cpf?: string | null
  nome?: string | null
  email?: string | null
  telefone?: string | null
  idUf?: number | null
  idMunicipio?: number | null
}

export type ConvidadaAcessarPayload = {
  codigoConvite: string
  cnpjEmpresa: string
  razaoSocial: string
  nomeFantasia: string
  idSetor: number
  idRamo: number
  cpf: string
  nomeColaborador: string
  emailColaborador: string
  telefoneColaborador: string
  idUf: number
  idMunicipio: number
  senha: string
  confirmacaoSenha: string
  cargo: number
}

export type ConvidadaAcessarResult = {
  ok: boolean
  errorMessage?: string | null
  redirectUrl?: string | null
}

async function readJson<T>(res: Response): Promise<T> {
  const data = (await res.json().catch(() => ({}))) as T & { errorMessage?: string }
  if (!res.ok) {
    const msg =
      (data as { errorMessage?: string }).errorMessage ||
      `HTTP ${res.status}`
    throw new Error(msg)
  }
  return data
}

export async function fetchConvidadaBootstrap(codigo: string): Promise<ConvidadaBootstrap> {
  const q = encodeURIComponent(codigo)
  const res = await fetch(`/api/bff/convidada/bootstrap?o=${q}`, {
    credentials: 'include',
  })
  return readJson<ConvidadaBootstrap>(res)
}

export async function fetchConvidadaMunicipios(idUf: number): Promise<ConvidadaLookup[]> {
  const res = await fetch('/api/bff/convidada/municipios', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ idUf }),
  })
  return readJson<ConvidadaLookup[]>(res)
}

export async function fetchEmpresaPorCnpj(cnpj: string): Promise<ConvidadaEmpresaHint> {
  const res = await fetch('/api/bff/convidada/empresa-cnpj', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ cnpj }),
  })
  return readJson<ConvidadaEmpresaHint>(res)
}

export async function fetchColaboradorPorCpf(cpf: string): Promise<ConvidadaColaboradorHint> {
  const res = await fetch('/api/bff/convidada/colaborador-cpf', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ cpf }),
  })
  return readJson<ConvidadaColaboradorHint>(res)
}

export async function acessarConvidada(
  payload: ConvidadaAcessarPayload,
): Promise<ConvidadaAcessarResult> {
  const res = await fetch('/api/bff/convidada/acessar', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify(payload),
  })
  return readJson<ConvidadaAcessarResult>(res)
}
