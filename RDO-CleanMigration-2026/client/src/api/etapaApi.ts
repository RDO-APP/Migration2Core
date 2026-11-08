export type EtapaCadastroBlank = {
  id?: number
  titulo?: string
  ordemSugerida: number
}

export type EtapaCadastroSaveResult = {
  ok: boolean
  id?: number
  errorMessage?: string
}

export type EtapaListItem = {
  id: number
  titulo: string
  ordem: number
}

export type EtapaListResponse = {
  obraNome: string
  items: EtapaListItem[]
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

export async function fetchEtapaLista(titulo = ''): Promise<EtapaListResponse> {
  const q = new URLSearchParams()
  if (titulo.trim()) q.set('titulo', titulo.trim())
  const qs = q.toString()
  const res = await fetch(`/api/bff/etapas/lista${qs ? `?${qs}` : ''}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'lista etapas')
}

export async function fetchEtapaCadastroBlank(id?: number): Promise<EtapaCadastroBlank> {
  const q = id && id > 0 ? `?id=${id}` : ''
  const res = await fetch(`/api/bff/etapas/cadastro${q}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro etapa')
}

export async function saveEtapaCadastro(body: {
  id?: number
  titulo: string
  ordem: number
}): Promise<EtapaCadastroSaveResult> {
  const res = await fetch('/api/bff/etapas', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar etapa')
}

export async function deleteEtapa(id: number): Promise<EtapaCadastroSaveResult> {
  const res = await fetch(`/api/bff/etapas/${id}`, {
    method: 'DELETE',
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'excluir etapa')
}
