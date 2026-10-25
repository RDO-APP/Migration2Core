import type { ShellContext } from './equipamentos-api.types'

export async function fetchShellContext(): Promise<ShellContext> {
  const res = await fetch('/api/bff/shell', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  if (!res.ok) {
    throw new Error(res.status === 401 ? 'Sessão expirada.' : `Erro ${res.status} ao carregar shell.`)
  }
  return res.json() as Promise<ShellContext>
}
