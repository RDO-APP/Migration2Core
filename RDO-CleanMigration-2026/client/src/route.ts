export type OperadorPage = 'escolher' | 'cards'

/** SPA servida em /Obra/Escolher e /Tarefa/Cards pelo host MVC. */
export function detectOperadorPage(pathname = window.location.pathname): OperadorPage {
  const p = pathname.toLowerCase()
  if (p.includes('/obra/escolher')) {
    return 'escolher'
  }
  return 'cards'
}
