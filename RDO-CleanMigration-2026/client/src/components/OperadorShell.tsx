import {
  useEffect,
  useRef,
  useState,
  type FormEvent,
  type MouseEventHandler,
  type ReactNode,
} from 'react'
import type { ShellContext } from '../api/equipamentos-api.types'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import '../operador-shell.css'

function navClick(url: string): MouseEventHandler<HTMLAnchorElement> {
  return (e) => {
    e.preventDefault()
    goOperador(url)
  }
}

export type OperadorShellVariant = 'escolher' | 'cards'

type OperadorShellProps = {
  variant: OperadorShellVariant
  obraNome?: string
  usuarioNome?: string
  shell?: ShellContext | null
  children: ReactNode
}

function mergeNome(shell?: ShellContext | null, usuarioNome?: string): string {
  return (usuarioNome?.trim() || shell?.usuarioNome?.trim() || 'Operador').trim()
}

export function OperadorShell({ variant, obraNome, usuarioNome, shell, children }: OperadorShellProps) {
  const [userOpen, setUserOpen] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [mobileUserOpen, setMobileUserOpen] = useState(false)
  const userRef = useRef<HTMLLIElement>(null)
  const nome = mergeNome(shell, usuarioNome)
  const tituloObra = (obraNome ?? shell?.obraNome)?.trim().toUpperCase() ?? ''
  const logoHref = P3_NAV.header.logoEscolher

  useEffect(() => {
    function onDocClick(e: MouseEvent) {
      if (userRef.current && !userRef.current.contains(e.target as Node)) {
        setUserOpen(false)
      }
    }
    document.addEventListener('click', onDocClick)
    return () => document.removeEventListener('click', onDocClick)
  }, [])

  function submitLogout(e: FormEvent) {
    if (!shell?.antiforgeryFieldName || !shell.antiforgeryToken) {
      e.preventDefault()
      window.location.assign('/Account/Login')
    }
  }

  const showChart = shell?.showChart ?? true
  const showNovaObra = shell?.showNovaObra ?? true
  const showDashboard = shell?.showDashboardObra ?? false
  const menuPaginas = shell?.menuPaginas ?? []

  function closeMobileMenu() {
    setMobileMenuOpen(false)
    setMobileUserOpen(false)
  }

  function mobileNavClick(href: string): MouseEventHandler<HTMLAnchorElement> {
    return (e) => {
      e.preventDefault()
      closeMobileMenu()
      if (href && href !== '#') {
        goOperador(href)
      }
    }
  }

  return (
    <div
      className={`operador-app base ${variant === 'escolher' ? 'tema-azul' : 'tema-azul-claro'}${
        mobileMenuOpen ? ' operador-menu-open' : ''
      }`}
    >
      {mobileMenuOpen ? (
        <button
          type="button"
          className="operador-menu-backdrop"
          aria-label="Fechar menu"
          onClick={closeMobileMenu}
        />
      ) : null}
      <div className="topo">
        <nav className="navbar bg-blue-default">
          <div className="no-padding">
            <a className="navbar-brand logo pointer" href={logoHref}>
              <i className="icon-logo" aria-hidden />
            </a>
            <div className="menu-lateral">
              <ul className="nav-mobile">
                <li className="menu-container">
                  <input
                    id="menu-toggle"
                    type="checkbox"
                    className={mobileMenuOpen ? 'active' : undefined}
                    checked={mobileMenuOpen}
                    onChange={(e) => setMobileMenuOpen(e.target.checked)}
                    aria-hidden
                    tabIndex={-1}
                  />
                  <label htmlFor="menu-toggle" className="menu-button" aria-label="Abrir menu principal">
                    <svg className="icon-open" viewBox="0 0 24 24" aria-hidden>
                      <path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z" />
                    </svg>
                    <svg className="icon-close" viewBox="0 0 100 100" aria-hidden>
                      <path d="M83.288 88.13c-2.114 2.112-5.575 2.112-7.69 0L53.66 66.188c-2.113-2.112-5.572-2.112-7.686 0l-21.72 21.72c-2.114 2.113-5.572 2.113-7.687 0l-4.693-4.692c-2.114-2.114-2.114-5.573 0-7.688l21.72-21.72c2.112-2.115 2.112-5.574 0-7.687L11.87 24.4c-2.114-2.113-2.114-5.57 0-7.686l4.842-4.842c2.113-2.114 5.57-2.114 7.686 0l21.72 21.72c2.114 2.113 5.572 2.113 7.688 0l21.72-21.72c2.115-2.114 5.574-2.114 7.688 0l4.695 4.695c2.112 2.113 2.112 5.57-.002 7.686l-21.72 21.72c-2.112 2.114-2.112 5.573 0 7.686L88.13 75.6c2.112 2.11 2.112 5.572 0 7.687l-4.842 4.84z" />
                    </svg>
                  </label>

                  <div className={`menu-sidebar${mobileMenuOpen ? ' menu-sidebar-open' : ''}`}>
                    <div className="scrollbar-inner">
                      <ul className="nav navbar-nav navbar-right user">
                        <li className={mobileUserOpen ? 'open' : undefined}>
                          <a
                            href="#user-menu-mobile"
                            className="collapsed pointer"
                            aria-expanded={mobileUserOpen}
                            onClick={(e) => {
                              e.preventDefault()
                              setMobileUserOpen((v) => !v)
                            }}
                          >
                            <span className="image">
                              <img src="/images/user.png" alt="" />
                            </span>
                            <p>{nome}</p>
                          </a>
                          {mobileUserOpen ? (
                            <ul className="collapse multi-collapse in" id="user-menu-mobile">
                              <li>
                                <a href={P3_NAV.header.trocarSenha} onClick={mobileNavClick(P3_NAV.header.trocarSenha)}>
                                  TROCAR SENHA
                                </a>
                              </li>
                              <li>
                                <a
                                  href="/Account/Logout"
                                  onClick={(e) => {
                                    e.preventDefault()
                                    closeMobileMenu()
                                    const form = document.createElement('form')
                                    form.method = 'post'
                                    form.action = '/Account/Logout'
                                    if (shell?.antiforgeryFieldName && shell.antiforgeryToken) {
                                      const input = document.createElement('input')
                                      input.type = 'hidden'
                                      input.name = shell.antiforgeryFieldName
                                      input.value = shell.antiforgeryToken
                                      form.appendChild(input)
                                    }
                                    document.body.appendChild(form)
                                    form.submit()
                                  }}
                                >
                                  SAIR
                                </a>
                              </li>
                            </ul>
                          ) : null}
                        </li>
                      </ul>

                      <ul className="nav navbar-nav navbar-right ball-hover">
                        {menuPaginas.map((pagina) => (
                          <li key={`${pagina.href}-${pagina.titulo}`} className="btn-tooltip" title={pagina.titulo}>
                            <a href={pagina.href} className="collapsed collapsed-menu pointer" onClick={mobileNavClick(pagina.href)}>
                              <i className={pagina.cssClass} aria-hidden />
                              <span>{pagina.titulo}</span>
                            </a>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </li>
              </ul>
              {variant === 'cards' && tituloObra ? <h2 id="tituloObra">{tituloObra}</h2> : null}
            </div>
          </div>
          <div className="no-padding">
            <div className="navbar-collapse menu operador-menu-bar">
              <ul className="nav navbar-nav navbar-right ball-hover">
                {variant === 'cards' ? (
                  <>
                    {showDashboard ? (
                      <li className="btn-tooltip pointer" title="DASHBOARD DA OBRA">
                        <a href={P3_NAV.header.dashboardObra} onClick={navClick(P3_NAV.header.dashboardObra)}>
                          <i className="icon-dashboard" aria-hidden />
                        </a>
                      </li>
                    ) : null}
                    <li className="btn-tooltip pointer" title="RDO's">
                      <a href={P3_NAV.header.rdoListagem} onClick={navClick(P3_NAV.header.rdoListagem)}>
                        <i className="icon-rdo-novo_2" aria-hidden />
                      </a>
                    </li>
                    <li className="btn-tooltip pointer" title="TAREFAS">
                      <a href={P3_NAV.header.tarefaCards} onClick={navClick(P3_NAV.header.tarefaCards)}>
                        <i className="fa fa-th" aria-hidden />
                      </a>
                    </li>
                  </>
                ) : null}
                {showChart ? (
                  <li className="btn-tooltip pointer" title="DASHBOARD GERAL">
                    <a href={P3_NAV.header.chartGeral} onClick={navClick(P3_NAV.header.chartGeral)}>
                      <i className="fa fa-bar-chart" aria-hidden />
                    </a>
                  </li>
                ) : null}
                {showNovaObra ? (
                  <li className="btn-tooltip pointer" title="NOVA OBRA">
                    <a href={P3_NAV.header.novaObraCadastro} onClick={navClick(P3_NAV.header.novaObraCadastro)}>
                      <i className="fa fa-plus" aria-hidden />
                    </a>
                  </li>
                ) : null}
              </ul>

              <ul className="nav navbar-nav navbar-right user">
                <li ref={userRef} className={userOpen ? 'dropdown open' : 'dropdown'}>
                  <a
                    href="#"
                    className="dropdown-toggle pointer"
                    aria-expanded={userOpen}
                    onClick={(e) => {
                      e.preventDefault()
                      e.stopPropagation()
                      setUserOpen((v) => !v)
                    }}
                  >
                    <span className="image">
                      <img src="/images/user.png" alt="" />
                    </span>
                    <p>{nome}</p>
                    <i className="caret" aria-hidden />
                  </a>
                  {userOpen ? (
                    <ul className="dropdown-menu">
                      <li>
                        <a href={P3_NAV.header.trocarSenha} onClick={navClick(P3_NAV.header.trocarSenha)}>
                          TROCAR SENHA
                        </a>
                      </li>
                      <li>
                        <form action="/Account/Logout" method="post" onSubmit={submitLogout}>
                          {shell?.antiforgeryFieldName && shell.antiforgeryToken ? (
                            <input type="hidden" name={shell.antiforgeryFieldName} value={shell.antiforgeryToken} />
                          ) : null}
                          <button type="submit" className="dropdown-logout-btn">
                            SAIR
                          </button>
                        </form>
                      </li>
                    </ul>
                  ) : null}
                </li>
              </ul>
            </div>
          </div>
        </nav>
      </div>

      <main className="conteudo operador-conteudo">{children}</main>

      <footer className="footer">
        <div className="container">
          <p>RDO App Equipamentos © 2025. Todos os direitos reservados.</p>
        </div>
      </footer>
    </div>
  )
}
