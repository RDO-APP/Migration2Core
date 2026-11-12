export type EquipamentoIndexPermissions = {
  showVisualizar: boolean
  showEditar: boolean
  showDeletar: boolean
  showNovo: boolean
}

export type EquipamentoIndexBootstrap = {
  obraNomeSessao: string
  permissions: EquipamentoIndexPermissions
}

export type EquipamentoIndexFilter = {
  tipoEquipamento: string
  descricao: string
  marca: string
  modelo: string
  tipoAquisicao: string
  fabricanteFornecedor: string
}

export type EquipamentoIndexItem = {
  idEquipamento: number
  idObraEquipamento: number
  tipoEquipamento: string
  descricao: string
  fabricanteFornecedor: string
  contato: string
  telefone: string
}

export type EquipamentoIndexListResponse = {
  obraNomeSessao: string
  items: EquipamentoIndexItem[]
}

export type EquipamentoIndexActionResult = {
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

export async function fetchEquipamentoIndexBootstrap(): Promise<EquipamentoIndexBootstrap> {
  const res = await fetch('/api/bff/equipamentos/index/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap equipamentos')
}

export async function fetchEquipamentoIndexLista(
  filtro: EquipamentoIndexFilter,
): Promise<EquipamentoIndexListResponse> {
  const q = new URLSearchParams()
  if (filtro.tipoEquipamento.trim()) q.set('tipoEquipamento', filtro.tipoEquipamento.trim())
  if (filtro.descricao.trim()) q.set('descricao', filtro.descricao.trim())
  if (filtro.marca.trim()) q.set('marca', filtro.marca.trim())
  if (filtro.modelo.trim()) q.set('modelo', filtro.modelo.trim())
  if (filtro.tipoAquisicao && filtro.tipoAquisicao !== 'S') q.set('tipoAquisicao', filtro.tipoAquisicao)
  if (filtro.fabricanteFornecedor.trim()) q.set('fabricanteFornecedor', filtro.fabricanteFornecedor.trim())
  const qs = q.toString()
  const res = await fetch(`/api/bff/equipamentos/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista equipamentos')
}

export type EquipamentoCadastroForm = {
  idEquipamento: number
  idObraEquipamento: number
  tipoEquipamento: string
  descricao: string
  marca: string
  modelo: string
  tipoAquisicao: string
  dataAquisicao: string
  fabricanteFornecedor: string
  contato: string
  telefone: string
  podeSalvar: boolean
  obraNomeSessao: string
}

export type EquipamentoCadastroSaveRequest = {
  idEquipamento: number
  tipoEquipamento: string
  descricao: string
  marca: string
  modelo: string
  tipoAquisicao: string
  dataAquisicao: string
  fabricanteFornecedor: string
  contato: string
  telefone: string
}

export type EquipamentoCadastroSaveResult = {
  ok: boolean
  errorMessage?: string
  idEquipamento?: number
}

export async function fetchEquipamentoCadastro(id: number): Promise<EquipamentoCadastroForm> {
  const res = await fetch(`/api/bff/equipamentos/cadastro?id=${id}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro equipamento')
}

export async function saveEquipamentoCadastro(
  body: EquipamentoCadastroSaveRequest,
): Promise<EquipamentoCadastroSaveResult> {
  const res = await fetch('/api/bff/equipamentos/cadastro', {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar equipamento')
}

export async function deleteEquipamentoIndex(idEquipamento: number): Promise<EquipamentoIndexActionResult> {
  const res = await fetch(`/api/bff/equipamentos/${idEquipamento}`, {
    method: 'DELETE',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'excluir equipamento')
}
