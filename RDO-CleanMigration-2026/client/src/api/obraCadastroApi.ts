export type ObraCadastro = {
  id: number
  nova?: boolean
  descricao: string
  dataInicio: string
  dataPrevisaoFim: string
  logradouro: string
  numero: string
  bairro: string
  cep: string
  areaTotal?: number | null
  areaConstruida?: number | null
  cidadeEstado: string
  finalizada: boolean
}

export type ObraCadastroSaveResult = {
  ok: boolean
  errorMessage?: string | null
  obraNome?: string | null
  obraId?: number | null
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

export async function fetchObraCadastro(nova = false): Promise<ObraCadastro> {
  const q = nova ? '?nova=true' : ''
  const res = await fetch(`/api/bff/obras/cadastro${q}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro obra')
}

export async function saveObraCadastro(body: {
  nova?: boolean
  descricao: string
  dataInicio: string
  dataPrevisaoFim: string
  logradouro: string
  numero: string
  bairro: string
  cep: string
  areaTotal?: number | null
  areaConstruida?: number | null
}): Promise<ObraCadastroSaveResult> {
  // Flag de criação só na query (string) — evita 400 do model binder/JSON em bool `nova`.
  const { nova, ...fields } = body
  const q = nova ? '?nova=true' : ''
  const res = await fetch(`/api/bff/obras/cadastro${q}`, {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(fields),
  })
  return readJson(res, 'salvar obra')
}
