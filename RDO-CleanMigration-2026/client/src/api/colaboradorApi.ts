export type ColaboradorIndexLookup = { id: number; nome: string }

export type ColaboradorIndexPermissions = {
  showVisualizar: boolean
  showEditar: boolean
  showDeletar: boolean
  showNovo: boolean
}

export type ColaboradorIndexBootstrap = {
  obraNomeSessao: string
  ufs: ColaboradorIndexLookup[]
  cargos: ColaboradorIndexLookup[]
  grupos: ColaboradorIndexLookup[]
  permissions: ColaboradorIndexPermissions
}

export type ColaboradorIndexFilter = {
  nome: string
  cpf: string
  sexo: string
  email: string
  crea: string
  idUf: number
  idMunicipio: number
  idCargo: number
  idGrupo: number
  dataContratacao: string
}

export type ColaboradorIndexItem = {
  idColaborador: number
  nome: string
  descricaoCargo: string
  telefonePrincipal: string
  email: string
  descricaoGrupo: string
  editavel: boolean
  excluivel: boolean
}

export type ColaboradorIndexListResponse = {
  obraNomeSessao: string
  items: ColaboradorIndexItem[]
}

export type ColaboradorIndexActionResult = {
  ok: boolean
  errorMessage?: string
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

export async function fetchColaboradorIndexBootstrap(): Promise<ColaboradorIndexBootstrap> {
  const res = await fetch('/api/bff/colaboradores/index/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap colaboradores')
}

export async function fetchColaboradorIndexMunicipios(idUf: number): Promise<ColaboradorIndexLookup[]> {
  const res = await fetch(`/api/bff/colaboradores/index/municipios?idUf=${idUf}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'municípios')
}

export async function fetchColaboradorIndexLista(
  filtro: ColaboradorIndexFilter,
): Promise<ColaboradorIndexListResponse> {
  const q = new URLSearchParams()
  if (filtro.nome.trim()) q.set('nome', filtro.nome.trim())
  if (filtro.cpf.trim()) q.set('cpf', filtro.cpf.trim())
  if (filtro.sexo && filtro.sexo !== 'S') q.set('sexo', filtro.sexo)
  if (filtro.email.trim()) q.set('email', filtro.email.trim())
  if (filtro.crea.trim()) q.set('crea', filtro.crea.trim())
  if (filtro.idUf > 0) q.set('idUf', String(filtro.idUf))
  if (filtro.idMunicipio > 0) q.set('idMunicipio', String(filtro.idMunicipio))
  if (filtro.idCargo > 0) q.set('idCargo', String(filtro.idCargo))
  if (filtro.idGrupo > 0) q.set('idGrupo', String(filtro.idGrupo))
  if (filtro.dataContratacao.trim()) q.set('dataContratacao', filtro.dataContratacao.trim())
  const qs = q.toString()
  const res = await fetch(`/api/bff/colaboradores/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista colaboradores')
}

export type ColaboradorCadastroForm = {
  idColaborador: number
  cpf: string
  idGrupo: number
  nome: string
  idCargo: number
  sexo: string
  dataNascimento: string
  telefonePrincipal: string
  telefoneSecundario: string
  email: string
  crea: string
  dataContratacao: string
  logradouro: string
  numeroEndereco: string
  complemento: string
  bairro: string
  idUf: number
  idMunicipio: number
  cep: string
  podeSalvar: boolean
  exigeSenha: boolean
  obraNomeSessao: string
  ufs: ColaboradorIndexLookup[]
  cargos: ColaboradorIndexLookup[]
  grupos: ColaboradorIndexLookup[]
  municipios: ColaboradorIndexLookup[]
}

export type ColaboradorCadastroSaveRequest = {
  idColaborador: number
  cpf: string
  idGrupo: number
  nome: string
  idCargo: number
  sexo: string
  dataNascimento: string
  telefonePrincipal: string
  telefoneSecundario: string
  email: string
  crea: string
  dataContratacao: string
  logradouro: string
  numeroEndereco: string
  complemento: string
  bairro: string
  idMunicipio: number
  cep: string
  senha: string
  confirmacaoSenha: string
}

export type ColaboradorCadastroSaveResult = {
  ok: boolean
  errorMessage?: string
  idColaborador?: number
}

export async function fetchColaboradorCadastro(id: number): Promise<ColaboradorCadastroForm> {
  const res = await fetch(`/api/bff/colaboradores/cadastro?id=${id}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro colaborador')
}

export async function saveColaboradorCadastro(
  body: ColaboradorCadastroSaveRequest,
): Promise<ColaboradorCadastroSaveResult> {
  const res = await fetch('/api/bff/colaboradores/cadastro', {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar colaborador')
}

export async function deleteColaboradorIndex(idColaborador: number): Promise<ColaboradorIndexActionResult> {
  const res = await fetch(`/api/bff/colaboradores/${idColaborador}`, {
    method: 'DELETE',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'excluir colaborador')
}
