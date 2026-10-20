import type { ReactNode } from 'react'

type OperadorShellProps = {
  obraNome?: string
  usuarioNome?: string
  children: ReactNode
}

/** M4 — header/nav alinhado a _HeaderEscolher (EQ-W) + layout prod. */
export function OperadorShell({ obraNome, usuarioNome, children }: OperadorShellProps) {
  const obraTitulo = obraNome?.trim() ?? ''

  return (
    <div className="operador-app tema-azul base">
      <div className="topo">
        <nav className="navbar bg-blue-default">
          <div className="no-padding">
            <a className="navbar-brand logo pointer" href="/Obra/Escolher">
              <i className="icon-logo" aria-hidden />
              <span>Equipamentos</span>
            </a>
            <div className="menu-lateral">
              {obraTitulo ? <h2 id="tituloObra">{obraTitulo}</h2> : null}
            </div>
          </div>
          <div className="no-padding">
            <div className="navbar-collapse menu">
              <ul className="nav navbar-nav navbar-right user">
                <li className="dropdown">
                  <a href="/Obra/Escolher" className="dropdown-toggle pointer" role="button">
                    <span className="image">
                      <img src="/images/user.png" alt="" />
                    </span>
                    <p>{usuarioNome?.trim() || 'Operador'}</p>
                  </a>
                </li>
              </ul>
              <ul className="nav navbar-nav navbar-right ball-hover">
                <li className="btn-tooltip pointer" title="DASHBOARD GERAL">
                  <a href="/Chart">
                    <i className="fa fa-bar-chart" aria-hidden />
                  </a>
                </li>
                <li className="btn-tooltip pointer" title="NOVA UNIDADE ESCOLAR">
                  <a href="/Obra/Cadastro">
                    <i className="fa fa-plus" aria-hidden />
                  </a>
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
