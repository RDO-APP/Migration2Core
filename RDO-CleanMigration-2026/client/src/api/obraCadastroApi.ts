export type ObraCadastro = {
  id: number
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

export async function fetchObraCadastro(): Promise<ObraCadastro> {
  const res = await fetch('/api/bff/obras/cadastro', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro obra')
}

export async function saveObraCadastro(body: {
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
  const res = await fetch('/api/bff/obras/cadastro', {
    method: 'PUT',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar obra')
}
