import type { TarefaCadastro, TarefaCadastroSaveRequest, TarefaCadastroSaveResult } from './equipamentos-api.types'

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
      /* HTML ou texto puro */
    }
    const short =
      fromJson?.trim() ||
      (text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor (${fallback}).`
        : text.slice(0, 400) || `Erro ${res.status} (${fallback}).`)
    throw new Error(short)
  }
  return res.json() as Promise<T>
}

export async function fetchTarefaCadastro(id: number): Promise<TarefaCadastro> {
  const res = await fetch(`/api/bff/tarefas/${id}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro tarefa')
}

export async function saveTarefaCadastro(
  body: TarefaCadastroSaveRequest,
): Promise<TarefaCadastroSaveResult> {
  const res = await fetch('/api/bff/tarefas', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar tarefa')
}
