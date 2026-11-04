export type EtapaCadastroBlank = { ordemSugerida: number }

export type EtapaCadastroSaveResult = {
  ok: boolean
  id?: number
  errorMessage?: string
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

export async function fetchEtapaCadastroBlank(): Promise<EtapaCadastroBlank> {
  const res = await fetch('/api/bff/etapas/cadastro', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro etapa')
}

export async function saveEtapaCadastro(body: {
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
