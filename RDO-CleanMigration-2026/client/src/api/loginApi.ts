import type { LoginContext } from './equipamentos-api.types'

export async function fetchLoginContext(): Promise<LoginContext> {
  const res = await fetch('/api/bff/login/context', {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  if (!res.ok) {
    throw new Error(`Erro ${res.status} ao carregar login.`)
  }
  return res.json() as Promise<LoginContext>
}
