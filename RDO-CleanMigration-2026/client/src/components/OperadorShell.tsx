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

  return (
    <div className={`operador-app base ${variant === 'escolher' ? 'tema-azul' : 'tema-azul-claro'}`}>
      <div className="topo">
        <nav className="navbar bg-blue-default">
          <div className="no-padding">
            <a className="navbar-brand logo pointer" href={logoHref}>
              <i className="icon-logo" aria-hidden />
            </a>
            <div className="menu-lateral">
              {variant === 'cards' && tituloObra ? <h2 id="tituloObra">{tituloObra}</h2> : null}
            </div>
          </div>
          <div className="no-padding">
            <div className="navbar-collapse menu operador-menu-bar">
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
                        <a href={P3_NAV.header.trocarSenha}>TROCAR SENHA</a>
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
                      <a href={P3_NAV.header.tarefaCards}>
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
                  <li className="btn-tooltip pointer" title="NOVA UNIDADE ESCOLAR">
                    <a href={P3_NAV.header.novaObraCadastro} onClick={navClick(P3_NAV.header.novaObraCadastro)}>
                      <i className="fa fa-plus" aria-hidden />
                    </a>
                  </li>
                ) : null}
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
