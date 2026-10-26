export type OperadorPage = 'login' | 'escolher' | 'cards' | 'rdo'

/** SPA servida pelo host MVC (Login, Escolher, Cards, RDO listagem). */
export function detectOperadorPage(pathname = window.location.pathname): OperadorPage {
  const p = pathname.toLowerCase()
  if (p.includes('/account/login')) {
    return 'login'
  }
  if (p.includes('/obra/escolher')) {
    return 'escolher'
  }
  if (p.includes('/rdo/index')) {
    return 'rdo'
  }
  if (p.includes('/tarefa/cards')) {
    return 'cards'
  }
  return 'escolher'
}
