export type OperadorPage = 'login' | 'escolher' | 'cards' | 'rdo' | 'rdo-cadastro'

/** SPA servida pelo host MVC (Login, Escolher, Cards, P5a módulos). */
export function detectOperadorPage(pathname = window.location.pathname): OperadorPage {
  const p = pathname.toLowerCase()
  if (p.includes('/account/login')) {
    return 'login'
  }
  if (p.includes('/obra/escolher')) {
    return 'escolher'
  }
  if (p.includes('/rdo/cadastro')) {
    return 'rdo-cadastro'
  }
  if (p.includes('/rdo/index') || p === '/rdo' || p === '/rdo/') {
    return 'rdo'
  }
  if (p.includes('/tarefa/cards')) {
    return 'cards'
  }
  // P5a futuro (Chart, Dashboard…): fallback cards até página React existir.
  return 'cards'
}
