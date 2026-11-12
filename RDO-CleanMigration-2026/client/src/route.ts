export type OperadorPage =
  | 'login'
  | 'escolher'
  | 'cards'
  | 'tarefa-index'
  | 'rdo'
  | 'rdo-cadastro'
  | 'tarefa-cadastro'
  | 'etapa-cadastro'
  | 'etapa-index'
  | 'chart'
  | 'dashboard'
  | 'efetivo'
  | 'obra-cadastro'
  | 'obra-index'
  | 'empresa-index'
  | 'empresa-cadastro'
  | 'colaborador-index'
  | 'colaborador-cadastro'
  | 'equipamento-index'
  | 'equipamento-cadastro'

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
  if (p.includes('/etapa/index')) {
    return 'etapa-index'
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
  if (p.includes('/obra/index')) {
    return 'obra-index'
  }
  if (p.includes('/empresa/cadastro')) {
    return 'empresa-cadastro'
  }
  if (p.includes('/empresa/index')) {
    return 'empresa-index'
  }
  if (p.includes('/colaborador/cadastro')) {
    return 'colaborador-cadastro'
  }
  if (p.includes('/colaborador/index')) {
    return 'colaborador-index'
  }
  if (p.includes('/equipamento/cadastro') || p.includes('/equipamentos/cadastro')) {
    return 'equipamento-cadastro'
  }
  if (p.includes('/equipamento/index') || p.includes('/equipamentos/index')) {
    return 'equipamento-index'
  }
  if (p.includes('/tarefa/cards')) {
    return 'cards'
  }
  return 'cards'
}
