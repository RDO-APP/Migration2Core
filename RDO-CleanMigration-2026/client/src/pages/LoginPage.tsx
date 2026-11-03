import { useEffect, useState, type FormEvent } from 'react'
import { fetchLoginContext } from '../api/loginApi'
import '../login-page.css'

const LEMBRAR_CPF_KEY = 'rdo.login.cpf'

function maskCpf(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 11)
  let v = digits
  v = v.replace(/(\d{3})(\d)/, '$1.$2')
  v = v.replace(/(\d{3})(\d)/, '$1.$2')
  v = v.replace(/(\d{3})(\d{1,2})$/, '$1-$2')
  return v
}

function readSavedCpf(): string {
  try {
    const raw = localStorage.getItem(LEMBRAR_CPF_KEY)
    return raw ? maskCpf(raw) : ''
  } catch {
    return ''
  }
}

function persistCpf(cpf: string) {
  try {
    localStorage.setItem(LEMBRAR_CPF_KEY, cpf.replace(/\D/g, ''))
  } catch {
    /* quota / private mode */
  }
}

function clearSavedCpf() {
  try {
    localStorage.removeItem(LEMBRAR_CPF_KEY)
  } catch {
    /* ignore */
  }
}

export function LoginPage() {
  const [cpf, setCpf] = useState(readSavedCpf)
  const [senha, setSenha] = useState('')
  const [lembrarMe, setLembrarMe] = useState(() => readSavedCpf().length > 0)
  const [showSenha, setShowSenha] = useState(false)
  const [antiforgeryFieldName, setAntiforgeryFieldName] = useState('')
  const [antiforgeryToken, setAntiforgeryToken] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    fetchLoginContext()
      .then((ctx) => {
        if (!cancelled) {
          setAntiforgeryFieldName(ctx.antiforgeryFieldName)
          setAntiforgeryToken(ctx.antiforgeryToken)
        }
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : 'Falha ao preparar login.')
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  function onSubmit(e: FormEvent) {
    if (!antiforgeryFieldName || !antiforgeryToken) {
      e.preventDefault()
      setError('Token de segurança indisponível. Recarregue a página.')
      return
    }
    if (lembrarMe) {
      persistCpf(cpf)
    } else {
      clearSavedCpf()
    }
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <img src="/images/logo.jpg" alt="RDO App" className="login-logo" />
        <h1 className="login-title">Equipamentos</h1>

        {error ? <div className="login-alert login-alert-danger">{error}</div> : null}

        {loading ? (
          <p className="login-muted">Carregando…</p>
        ) : (
          <form
            method="post"
            action="/Account/Login"
            id="loginForm"
            autoComplete="on"
            onSubmit={onSubmit}
          >
            <input type="hidden" name={antiforgeryFieldName} value={antiforgeryToken} />

            <div className="login-form-group">
              <div className="login-input-group">
                <span className="login-input-icon icon-person" aria-hidden />
                <input
                  id="login-cpf"
                  name="Cpf"
                  type="text"
                  inputMode="numeric"
                  className="login-control"
                  placeholder="000.000.000-00"
                  maxLength={14}
                  autoComplete="username"
                  autoCorrect="off"
                  autoCapitalize="off"
                  spellCheck={false}
                  required
                  value={cpf}
                  onChange={(e) => setCpf(maskCpf(e.target.value))}
                />
              </div>
            </div>

            <div className="login-form-group">
              <div className="login-input-group">
                <span className="login-input-icon icon-lock" aria-hidden />
                <div className="login-password-wrap">
                  <input
                    name="Senha"
                    type={showSenha ? 'text' : 'password'}
                    className="login-control"
                    placeholder="SENHA"
                    autoComplete="current-password"
                    required
                    value={senha}
                    onChange={(e) => setSenha(e.target.value)}
                  />
                  <button
                    type="button"
                    className="login-password-toggle"
                    title="Mostrar/Ocultar senha"
                    onClick={() => setShowSenha((v) => !v)}
                  >
                    {showSenha ? '🙈' : '👁️'}
                  </button>
                </div>
              </div>
            </div>

            <div className="login-check">
              <input
                name="LembrarMe"
                type="checkbox"
                id="lembrarMe"
                checked={lembrarMe}
                onChange={(e) => setLembrarMe(e.target.checked)}
                value="true"
              />
              <label htmlFor="lembrarMe">Lembrar-me por 30 dias</label>
            </div>

            <a href="/Account/EsqueciSenha" className="login-forgot">
              Esqueci a senha
            </a>

            <button type="submit" className="login-submit">
              ACESSAR
            </button>
          </form>
        )}
      </div>
    </div>
  )
}
