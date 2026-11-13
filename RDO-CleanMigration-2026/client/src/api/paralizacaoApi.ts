export type ParalizacaoIndexPermissions = {
  showEditar: boolean
  showDeletar: boolean
  showNovo: boolean
}

export type ParalizacaoIndexBootstrap = {
  obraNomeSessao: string
  permissions: ParalizacaoIndexPermissions
}

export type ParalizacaoIndexFilter = {
  descricao: string
}

export type ParalizacaoIndexItem = {
  codigo: string
  descricao: string
  editavel: boolean
  excluivel: boolean
}

export type ParalizacaoIndexListResponse = {
  obraNomeSessao: string
  items: ParalizacaoIndexItem[]
}

export type ParalizacaoIndexActionResult = {
  ok: boolean
  errorMessage?: string
}

export type ParalizacaoCadastroForm = {
  codigo: string
  descricao: string
  update: boolean
  podeSalvar: boolean
  obraNomeSessao: string
}

export type ParalizacaoCadastroSaveRequest = {
  codigo: string
  descricao: string
  update: boolean
}

export type ParalizacaoCadastroSaveResult = {
  ok: boolean
  errorMessage?: string
  codigo?: string
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

export async function fetchParalizacaoIndexBootstrap(): Promise<ParalizacaoIndexBootstrap> {
  const res = await fetch('/api/bff/paralizacoes/index/bootstrap', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'bootstrap paralizações')
}

export async function fetchParalizacaoIndexLista(
  filtro: ParalizacaoIndexFilter,
): Promise<ParalizacaoIndexListResponse> {
  const q = new URLSearchParams()
  if (filtro.descricao.trim()) q.set('descricao', filtro.descricao.trim())
  const qs = q.toString()
  const res = await fetch(`/api/bff/paralizacoes/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista paralizações')
}

export async function fetchParalizacaoCadastro(codigo: string): Promise<ParalizacaoCadastroForm> {
  const q = codigo ? `?codigo=${encodeURIComponent(codigo)}` : ''
  const res = await fetch(`/api/bff/paralizacoes/cadastro${q}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro paralização')
}

export async function saveParalizacaoCadastro(
  body: ParalizacaoCadastroSaveRequest,
): Promise<ParalizacaoCadastroSaveResult> {
  const res = await fetch('/api/bff/paralizacoes/cadastro', {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar paralização')
}

export async function deleteParalizacaoIndex(codigo: string): Promise<ParalizacaoIndexActionResult> {
  const res = await fetch(`/api/bff/paralizacoes/${encodeURIComponent(codigo)}`, {
    method: 'DELETE',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'excluir paralização')
}
