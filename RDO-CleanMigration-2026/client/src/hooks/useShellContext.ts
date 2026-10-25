import { useEffect, useState } from 'react'
import { fetchShellContext } from '../api/shellApi'
import type { ShellContext } from '../api/equipamentos-api.types'

export function useShellContext() {
  const [shell, setShell] = useState<ShellContext | null>(null)
  const [shellError, setShellError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    fetchShellContext()
      .then((ctx) => {
        if (!cancelled) setShell(ctx)
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setShellError(e instanceof Error ? e.message : 'Falha ao carregar menu.')
        }
      })
    return () => {
      cancelled = true
    }
  }, [])

  return { shell, shellError }
}
