export type OperadorPage =
  | 'login'
  | 'escolher'
  | 'cards'
  | 'tarefa-index'
  | 'rdo'
  | 'rdo-cadastro'
  | 'tarefa-cadastro'
  | 'etapa-cadastro'
  | 'chart'
  | 'dashboard'
  | 'efetivo'
  | 'obra-cadastro'

/** SPA servida pelo host MVC (Login, Escolher, Cards, P5a módulos). */
export function detectOperadorPage(pathname = window.location.pathname): OperadorPage {
  const p = pathname.toLowerCase()
  if (p.includes('/account/login')) {
    return 'login'
  }
  if (p.includes('/obra/escolher')) {
    return 'escolher'
  }
  if (p.includes('/tarefa/cadastro')) {
    return 'tarefa-cadastro'
  }
  if (p.includes('/tarefa/index')) {
    return 'tarefa-index'
  }
  if (p.includes('/etapa/cadastro')) {
    return 'etapa-cadastro'
  }
  if (p.includes('/rdo/cadastro')) {
    return 'rdo-cadastro'
  }
  if (p.includes('/rdo/index') || p === '/rdo' || p === '/rdo/') {
    return 'rdo'
  }
  if (p.includes('/chart')) {
    return 'chart'
  }
  if (p.includes('/dashboard')) {
    return 'dashboard'
  }
  if (p.includes('/efetivo')) {
    return 'efetivo'
  }
  if (p.includes('/obra/cadastro')) {
    return 'obra-cadastro'
  }
  if (p.includes('/tarefa/cards')) {
    return 'cards'
  }
  return 'cards'
}
