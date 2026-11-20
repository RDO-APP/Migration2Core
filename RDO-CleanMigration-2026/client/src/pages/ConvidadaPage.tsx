import { useEffect, useMemo, useState, type FormEvent } from 'react'
import {
  acessarConvidada,
  fetchColaboradorPorCpf,
  fetchConvidadaBootstrap,
  fetchConvidadaMunicipios,
  fetchEmpresaPorCnpj,
  type ConvidadaLookup,
} from '../api/convidadaApi'
import '../convidada-page.css'

function digits(value: string, max: number): string {
  return value.replace(/\D/g, '').slice(0, max)
}

function maskCnpj(value: string): string {
  const d = digits(value, 14)
  return d
    .replace(/^(\d{2})(\d)/, '$1.$2')
    .replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3')
    .replace(/\.(\d{3})(\d)/, '.$1/$2')
    .replace(/(\d{4})(\d)/, '$1-$2')
}

function maskCpf(value: string): string {
  const d = digits(value, 11)
  return d
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d{1,2})$/, '$1-$2')
}

function maskPhone(value: string): string {
  const d = digits(value, 11)
  if (d.length <= 10) {
    return d.replace(/(\d{2})(\d{4})(\d{0,4})/, '($1)$2-$3').replace(/-$/, '')
  }
  return d.replace(/(\d{2})(\d{5})(\d{0,4})/, '($1)$2-$3').replace(/-$/, '')
}

function readCodigoFromUrl(): string {
  try {
    return new URLSearchParams(window.location.search).get('o')?.trim() ?? ''
  } catch {
    return ''
  }
}

export function ConvidadaPage() {
  const codigo = useMemo(() => readCodigoFromUrl(), [])
  const [loading, setLoading] = useState(true)
  const [ready, setReady] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [nomeObra, setNomeObra] = useState('')
  const [papel, setPapel] = useState('')
  const [ufs, setUfs] = useState<ConvidadaLookup[]>([])
  const [municipios, setMunicipios] = useState<ConvidadaLookup[]>([])
  const [setores, setSetores] = useState<ConvidadaLookup[]>([])
  const [ramos, setRamos] = useState<ConvidadaLookup[]>([])
  const [cargos, setCargos] = useState<ConvidadaLookup[]>([])
  const [lockEmpresa, setLockEmpresa] = useState(false)
  const [lockUser, setLockUser] = useState(false)

  const [cnpj, setCnpj] = useState('')
  const [razao, setRazao] = useState('')
  const [fantasia, setFantasia] = useState('')
  const [idSetor, setIdSetor] = useState(0)
  const [idRamo, setIdRamo] = useState(0)
  const [cpf, setCpf] = useState('')
  const [nome, setNome] = useState('')
  const [email, setEmail] = useState('')
  const [telefone, setTelefone] = useState('')
  const [idUf, setIdUf] = useState(0)
  const [idMunicipio, setIdMunicipio] = useState(0)
  const [senha, setSenha] = useState('')
  const [confSenha, setConfSenha] = useState('')
  const [cargo, setCargo] = useState(0)

  useEffect(() => {
    let cancelled = false
    if (!codigo) {
      setError('Link de convite inválido (parâmetro o ausente).')
      setLoading(false)
      return
    }

    fetchConvidadaBootstrap(codigo)
      .then((boot) => {
        if (cancelled) return
        if (!boot.ok) {
          setError(boot.errorMessage || 'Convite inválido.')
          setReady(false)
          return
        }
        setNomeObra(boot.nomeObra)
        setPapel(boot.papel)
        setUfs(boot.ufs ?? [])
        setSetores(boot.setores ?? [])
        setRamos(boot.ramos ?? [])
        setCargos(boot.cargos ?? [])
        setReady(true)
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : 'Falha ao validar convite.')
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })

    return () => {
      cancelled = true
    }
  }, [codigo])

  useEffect(() => {
    if (idUf <= 0) {
      setMunicipios([])
      setIdMunicipio(0)
      return
    }
    let cancelled = false
    fetchConvidadaMunicipios(idUf)
      .then((list) => {
        if (!cancelled) setMunicipios(list)
      })
      .catch(() => {
        if (!cancelled) setMunicipios([])
      })
    return () => {
      cancelled = true
    }
  }, [idUf])

  async function onBlurCnpj() {
    if (digits(cnpj, 14).length !== 14) return
    try {
      const hint = await fetchEmpresaPorCnpj(cnpj)
      if (hint.found) {
        setRazao(hint.razaoSocial ?? '')
        setFantasia(hint.nomeFantasia ?? '')
        setIdSetor(hint.idSetor ?? 0)
        setIdRamo(hint.idRamo ?? 0)
        setLockEmpresa(true)
      } else {
        setLockEmpresa(false)
      }
    } catch {
      setLockEmpresa(false)
    }
  }

  async function onBlurCpf() {
    if (digits(cpf, 11).length !== 11) return
    try {
      const hint = await fetchColaboradorPorCpf(cpf)
      if (hint.found) {
        setNome(hint.nome ?? '')
        setEmail(hint.email ?? '')
        setTelefone(maskPhone(hint.telefone ?? ''))
        if (hint.idUf) setIdUf(hint.idUf)
        if (hint.idMunicipio) setIdMunicipio(hint.idMunicipio)
        setLockUser(true)
      } else {
        setLockUser(false)
      }
    } catch {
      setLockUser(false)
    }
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setSaving(true)
    try {
      const result = await acessarConvidada({
        codigoConvite: codigo,
        cnpjEmpresa: cnpj,
        razaoSocial: razao,
        nomeFantasia: fantasia,
        idSetor,
        idRamo,
        cpf,
        nomeColaborador: nome,
        emailColaborador: email,
        telefoneColaborador: telefone,
        idUf,
        idMunicipio,
        senha,
        confirmacaoSenha: confSenha,
        cargo,
      })
      if (!result.ok) {
        setError(result.errorMessage || 'Não foi possível aceitar o convite.')
        return
      }
      window.location.href = result.redirectUrl || '/Obra/Escolher'
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao acessar.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="convidada-page">
      <div className="convidada-card">
        <img src="/images/logo.jpg" alt="RDO App" className="convidada-logo" />
        <h1 className="convidada-title">Aceite de convite</h1>
        {nomeObra ? (
          <p className="convidada-sub">
            Obra <strong>{nomeObra}</strong>
            {papel ? <> · papel <strong>{papel}</strong></> : null}
          </p>
        ) : (
          <p className="convidada-sub">Preencha os dados da empresa e do usuário</p>
        )}

        {error ? <div className="convidada-alert convidada-alert-danger">{error}</div> : null}
        {loading ? <p className="convidada-muted">Validando convite…</p> : null}

        {!loading && ready ? (
          <form onSubmit={onSubmit}>
            <h2 className="convidada-h2">Dados da Empresa</h2>
            <div className="convidada-grid">
              <div className="convidada-field">
                <label>CNPJ</label>
                <input
                  value={cnpj}
                  onChange={(e) => {
                    setCnpj(maskCnpj(e.target.value))
                    setLockEmpresa(false)
                  }}
                  onBlur={onBlurCnpj}
                  placeholder="00.000.000/0000-00"
                  disabled={lockEmpresa && false}
                />
              </div>
              <div className="convidada-field">
                <label>Razão Social</label>
                <input value={razao} onChange={(e) => setRazao(e.target.value)} disabled={lockEmpresa} />
              </div>
              <div className="convidada-field">
                <label>Nome Fantasia</label>
                <input
                  value={fantasia}
                  onChange={(e) => setFantasia(e.target.value)}
                  disabled={lockEmpresa}
                />
              </div>
              <div className="convidada-field">
                <label>Setor</label>
                <select
                  value={idSetor}
                  onChange={(e) => setIdSetor(Number(e.target.value))}
                  disabled={lockEmpresa}
                >
                  <option value={0}>Selecione…</option>
                  {setores.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.nome}
                    </option>
                  ))}
                </select>
              </div>
              <div className="convidada-field">
                <label>Ramo</label>
                <select
                  value={idRamo}
                  onChange={(e) => setIdRamo(Number(e.target.value))}
                  disabled={lockEmpresa}
                >
                  <option value={0}>Selecione…</option>
                  {ramos.map((r) => (
                    <option key={r.id} value={r.id}>
                      {r.nome}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <h2 className="convidada-h2">Dados do Usuário</h2>
            <div className="convidada-grid">
              <div className="convidada-field">
                <label>CPF</label>
                <input
                  value={cpf}
                  onChange={(e) => {
                    setCpf(maskCpf(e.target.value))
                    setLockUser(false)
                  }}
                  onBlur={onBlurCpf}
                  placeholder="000.000.000-00"
                />
              </div>
              <div className="convidada-field">
                <label>Nome</label>
                <input value={nome} onChange={(e) => setNome(e.target.value)} disabled={lockUser} />
              </div>
              <div className="convidada-field">
                <label>E-mail</label>
                <input
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  disabled={lockUser}
                  type="email"
                />
              </div>
              <div className="convidada-field">
                <label>Telefone</label>
                <input
                  value={telefone}
                  onChange={(e) => setTelefone(maskPhone(e.target.value))}
                  disabled={lockUser}
                />
              </div>
              <div className="convidada-field">
                <label>UF</label>
                <select
                  value={idUf}
                  onChange={(e) => {
                    setIdUf(Number(e.target.value))
                    setIdMunicipio(0)
                  }}
                  disabled={lockUser}
                >
                  <option value={0}>Selecione…</option>
                  {ufs.map((u) => (
                    <option key={u.id} value={u.id}>
                      {u.nome}
                    </option>
                  ))}
                </select>
              </div>
              <div className="convidada-field">
                <label>Município</label>
                <select
                  value={idMunicipio}
                  onChange={(e) => setIdMunicipio(Number(e.target.value))}
                  disabled={lockUser || idUf <= 0}
                >
                  <option value={0}>Selecione…</option>
                  {municipios.map((m) => (
                    <option key={m.id} value={m.id}>
                      {m.nome}
                    </option>
                  ))}
                </select>
              </div>
              <div className="convidada-field">
                <label>Senha</label>
                <input
                  type="password"
                  value={senha}
                  onChange={(e) => setSenha(e.target.value)}
                  autoComplete="new-password"
                />
              </div>
              <div className="convidada-field">
                <label>Confirmação da Senha</label>
                <input
                  type="password"
                  value={confSenha}
                  onChange={(e) => setConfSenha(e.target.value)}
                  autoComplete="new-password"
                />
              </div>
              <div className="convidada-field">
                <label>Cargo</label>
                <select value={cargo} onChange={(e) => setCargo(Number(e.target.value))}>
                  <option value={0}>Selecione o cargo…</option>
                  {cargos.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.nome}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="convidada-actions">
              <button
                type="button"
                className="convidada-btn convidada-btn-cancel"
                onClick={() => {
                  window.location.href = '/Account/Login'
                }}
              >
                CANCELAR
              </button>
              <button type="submit" className="convidada-btn convidada-btn-ok" disabled={saving}>
                {saving ? 'Salvando…' : 'ACESSAR'}
              </button>
            </div>
          </form>
        ) : null}

        {!loading && error && !codigo ? (
          <div className="convidada-actions">
            <button
              type="button"
              className="convidada-btn convidada-btn-ok"
              onClick={() => {
                window.location.href = '/Account/Login'
              }}
            >
              Ir para Login
            </button>
          </div>
        ) : null}
      </div>
    </div>
  )
}
