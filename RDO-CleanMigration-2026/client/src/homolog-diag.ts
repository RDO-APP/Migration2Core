/** Homolog: diagnóstico só via /Homolog/F12 e Console — sem UI nas telas P1–P5. */
export function initHomologDiag(): void {
  const host = window.location.hostname
  if (!host.includes('homolog.sistema.rdoapp.com.br')) {
    return
  }

  const path = window.location.pathname.toLowerCase()
  if (path.startsWith('/homolog/')) {
    return
  }

  // Console opcional (invisível) — não injeta rodapé na SPA operador.
  const page = path.includes('/rdo/index') ? 'rdo' : path.includes('/tarefa/cards') ? 'cards' : 'outro'
  console.info(`[RDO homolog] pagina=${page} path=${window.location.pathname} · debug: /Homolog/F12`)
}
