import { useEffect, useRef, useState } from 'react'
import {
  fetchColaboradorCadastro,
  fetchColaboradorIndexMunicipios,
  saveColaboradorCadastro,
  type ColaboradorCadastroForm,
  type ColaboradorIndexLookup,
} from '../api/colaboradorApi'
import { fetchViaCep } from '../api/obraCadastroApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'
import '../rdo-cadastro.css'

function idFromUrl(): number {
  const raw = new URLSearchParams(window.location.search).get('id')
  const n = raw ? Number(raw) : NaN
  return Number.isFinite(n) && n > 0 ? n : 0
}

function isVisualizar(): boolean {
  return new URLSearchParams(window.location.search).get('modo') === 'visualizar'
}

function digitsOnly(v: string, max: number) {
  return v.replace(/\D/g, '').slice(0, max)
}

function isPerfilColaboradorLeve(grupos: ColaboradorIndexLookup[], idGrupo: number): boolean {
  const g = grupos.find((x) => x.id === idGrupo)
  const n = (g?.nome ?? '').trim().toLowerCase()
  return n === 'colaborador' || n === 'terceirizado'
}

function Req({ show }: { show: boolean }) {
  return show ? <span style={{ color: 'red' }}>*</span> : null
}

function matchMunicipio(list: ColaboradorIndexLookup[], localidade: string): number {
  const target = localidade.trim().toLowerCase()
  if (!target) return 0
  const exact = list.find((m) => m.nome.trim().toLowerCase() === target)
  if (exact) return exact.id
  const partial = list.find(
    (m) =>
      m.nome.trim().toLowerCase().includes(target) || target.includes(m.nome.trim().toLowerCase()),
  )
  return partial?.id ?? 0
}

export function ColaboradorCadastroPage() {
  const { shell } = useShellContext()
  const id = idFromUrl()
  const visualizar = isVisualizar()
  const [form, setForm] = useState<ColaboradorCadastroForm | null>(null)
  const [municipios, setMunicipios] = useState<ColaboradorIndexLookup[]>([])
  const [senha, setSenha] = useState('')
  const [confirmacaoSenha, setConfirmacaoSenha] = useState('')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [cepBusy, setCepBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const lastCepLookup = useRef('')

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const data = await fetchColaboradorCadastro(id)
        if (cancelled) return
        // Novo: CEP vazio (não herdar obra / autofill)
        const normalized = data.idColaborador <= 0 ? { ...data, cep: '' } : data
        setForm(normalized)
        setMunicipios(normalized.municipios)
      } catch (e: unknown) {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar colaborador.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [id])

  const readOnly = visualizar || (form != null && !form.podeSalvar)
  const perfilLeve = form ? isPerfilColaboradorLeve(form.grupos, form.idGrupo) : false
  const showSenha = !!form && !perfilLeve && (form.exigeSenha || form.idColaborador === 0) && !readOnly
  const reqFull = !perfilLeve

  async function onChangeUf(idUf: number) {
    if (!form) return
    setForm({ ...form, idUf, idMunicipio: 0 })
    if (idUf <= 0) {
      setMunicipios([])
      return
    }
    try {
      setMunicipios(await fetchColaboradorIndexMunicipios(idUf))
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao carregar municípios.')
      setMunicipios([])
    }
  }

  async function lookupCep(raw: string) {
    if (!form || readOnly) return
    const cep = digitsOnly(raw, 8)
    if (cep.length !== 8) return
    if (cep === lastCepLookup.current && !cepBusy) return
    lastCepLookup.current = cep
    setCepBusy(true)
    try {
      const via = await fetchViaCep(cep)
      if (!via) {
        showToast('error', 'CEP não encontrado.')
        return
      }
      const ufId =
        form.ufs.find((u) => u.nome.trim().toUpperCase() === (via.uf ?? '').trim().toUpperCase())
          ?.id ?? 0
      let munList = municipios
      if (ufId > 0) {
        munList = await fetchColaboradorIndexMunicipios(ufId)
        setMunicipios(munList)
      }
      setForm((prev) =>
        prev
          ? {
              ...prev,
              cep,
              logradouro: via.logradouro?.trim() || prev.logradouro,
              bairro: via.bairro?.trim() || prev.bairro,
              idUf: ufId || prev.idUf,
              idMunicipio: ufId > 0 ? matchMunicipio(munList, via.localidade ?? '') : prev.idMunicipio,
            }
          : prev,
      )
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao consultar CEP.')
    } finally {
      setCepBusy(false)
    }
  }

  function validateBeforeSave(): string | null {
    if (!form) return 'Formulário inválido.'
    if (form.idGrupo <= 0) return 'O Perfil deve ser preenchido.'
    if (form.nome.trim().length < 3) return 'Por favor, introduza pelo menos três caracteres no Nome.'
    if (form.idCargo <= 0) return 'O Cargo deve ser preenchido.'
    if (!form.numeroEndereco.trim()) return 'O Número deve ser preenchido.'
    if (digitsOnly(form.cep, 8).length !== 8) return 'O CEP deve ser preenchido.'
    if (!perfilLeve) {
      if (digitsOnly(form.cpf, 11).length !== 11) return 'O CPF deve ser preenchido.'
      if (form.sexo !== 'M' && form.sexo !== 'F') return 'O Sexo deve ser preenchido.'
      if (form.dataNascimento.replace(/\D/g, '').length !== 8) return 'A Data de Nascimento deve ser preenchida.'
      if (digitsOnly(form.telefonePrincipal, 15).length < 10) return 'O Telefone Principal deve ser preenchido.'
      if (!form.email.trim()) return 'O E-mail precisa ser preenchido.'
      if (!form.logradouro.trim()) return 'O Logradouro deve ser preenchido.'
      if (form.idMunicipio <= 0) return 'O Município deve ser preenchido.'
      if (form.idColaborador <= 0 || senha || confirmacaoSenha) {
        if (senha.length < 4) return 'Por favor, introduza pelo menos 4 caracteres na Senha do Colaborador.'
        if (!confirmacaoSenha) return 'A Confirmação Senha deve ser preenchida.'
        if (senha !== confirmacaoSenha) return 'As senhas digitadas devem ser idênticas.'
      }
    }
    return null
  }

  async function onSave() {
    if (!form || readOnly) return
    const err = validateBeforeSave()
    if (err) {
      showToast('error', err)
      return
    }
    setSaving(true)
    try {
      const result = await saveColaboradorCadastro({
        idColaborador: form.idColaborador,
        cpf: form.cpf,
        idGrupo: form.idGrupo,
        nome: form.nome,
        idCargo: form.idCargo,
        sexo: form.sexo,
        dataNascimento: form.dataNascimento,
        telefonePrincipal: form.telefonePrincipal,
        telefoneSecundario: form.telefoneSecundario,
        email: form.email,
        crea: form.crea,
        dataContratacao: form.dataContratacao,
        logradouro: form.logradouro,
        numeroEndereco: form.numeroEndereco,
        complemento: form.complemento,
        bairro: form.bairro,
        idMunicipio: form.idMunicipio,
        cep: form.cep,
        senha,
        confirmacaoSenha,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador('/colaborador/index')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <OperadorShell variant="cards" obraNome={form?.obraNomeSessao || shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page rdo-cadastro-page">
        <div className="panel-heading">
          <h3>Colaborador</h3>
        </div>
        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <p className="error">{error}</p> : null}
        {!loading && !error && form ? (
          <form
            className="panel efetivo-filtros"
            autoComplete="off"
            style={{ gridTemplateColumns: 'repeat(12, minmax(0, 1fr))' }}
            onSubmit={(e) => {
              e.preventDefault()
              void onSave()
            }}
          >
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                CPF
                <Req show={reqFull} />
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={14}
                autoComplete="off"
                disabled={readOnly || form.idColaborador > 0}
                value={form.cpf}
                onChange={(e) => setForm({ ...form, cpf: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">
                Perfil do Colaborador<span style={{ color: 'red' }}>*</span>
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.idGrupo}
                onChange={(e) => setForm({ ...form, idGrupo: Number(e.target.value) || 0 })}
              >
                <option value={0}>Selecione...</option>
                {form.grupos.map((g) => (
                  <option key={g.id} value={g.id}>
                    {g.nome}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">
                Nome do Colaborador<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoFocus
                autoComplete="off"
                disabled={readOnly}
                value={form.nome}
                onChange={(e) => setForm({ ...form, nome: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Cargo<span style={{ color: 'red' }}>*</span>
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.idCargo}
                onChange={(e) => setForm({ ...form, idCargo: Number(e.target.value) || 0 })}
              >
                <option value={0}>Selecione...</option>
                {form.cargos.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.nome}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Sexo
                <Req show={reqFull} />
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.sexo}
                onChange={(e) => setForm({ ...form, sexo: e.target.value })}
              >
                <option value="S">Selecione...</option>
                <option value="M">Masculino</option>
                <option value="F">Feminino</option>
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Data de Nascimento
                <Req show={reqFull} />
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={10}
                placeholder="dd/mm/aaaa"
                autoComplete="off"
                disabled={readOnly}
                value={form.dataNascimento}
                onChange={(e) => setForm({ ...form, dataNascimento: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Telefone Principal
                <Req show={reqFull} />
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={15}
                autoComplete="off"
                disabled={readOnly}
                value={form.telefonePrincipal}
                onChange={(e) => setForm({ ...form, telefonePrincipal: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Telefone Secundário</label>
              <input
                type="text"
                className="form-control"
                maxLength={15}
                autoComplete="off"
                disabled={readOnly}
                value={form.telefoneSecundario}
                onChange={(e) => setForm({ ...form, telefoneSecundario: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                E-mail
                <Req show={reqFull} />
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoComplete="off"
                disabled={readOnly}
                value={form.email}
                onChange={(e) => setForm({ ...form, email: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">CREA</label>
              <input
                type="text"
                className="form-control"
                maxLength={20}
                autoComplete="off"
                disabled={readOnly}
                value={form.crea}
                onChange={(e) => setForm({ ...form, crea: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Data da Contratação</label>
              <input
                type="text"
                className="form-control"
                maxLength={10}
                placeholder="dd/mm/aaaa"
                autoComplete="off"
                disabled={readOnly}
                value={form.dataContratacao}
                onChange={(e) => setForm({ ...form, dataContratacao: e.target.value })}
              />
            </div>

            {/* Endereço: CEP primeiro (ViaCEP) — melhoria vs prod (CEP no fim) */}
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                CEP<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                name="colaborador_cep_novo"
                maxLength={9}
                autoComplete="off"
                disabled={readOnly || cepBusy}
                value={form.cep}
                placeholder={cepBusy ? 'Buscando…' : '00000000'}
                onChange={(e) => {
                  const next = digitsOnly(e.target.value, 8)
                  setForm({ ...form, cep: next })
                  if (next.length === 8) void lookupCep(next)
                }}
                onBlur={() => void lookupCep(form.cep)}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">
                Logradouro
                <Req show={reqFull} />
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoComplete="off"
                disabled={readOnly}
                value={form.logradouro}
                onChange={(e) => setForm({ ...form, logradouro: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Número<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={5}
                autoComplete="off"
                disabled={readOnly}
                value={form.numeroEndereco}
                onChange={(e) => setForm({ ...form, numeroEndereco: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">Complemento</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoComplete="off"
                disabled={readOnly}
                value={form.complemento}
                onChange={(e) => setForm({ ...form, complemento: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Bairro</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoComplete="off"
                disabled={readOnly}
                value={form.bairro}
                onChange={(e) => setForm({ ...form, bairro: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                UF
                <Req show={reqFull} />
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.idUf}
                onChange={(e) => void onChangeUf(Number(e.target.value) || 0)}
              >
                <option value={0}>Selecione...</option>
                {form.ufs.map((u) => (
                  <option key={u.id} value={u.id}>
                    {u.nome}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Município
                <Req show={reqFull} />
              </label>
              <select
                className="form-control"
                disabled={readOnly || form.idUf <= 0}
                value={form.idMunicipio}
                onChange={(e) => setForm({ ...form, idMunicipio: Number(e.target.value) || 0 })}
              >
                <option value={0}>Selecione...</option>
                {municipios.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.nome}
                  </option>
                ))}
              </select>
            </div>
            {showSenha ? (
              <>
                <div className="form-group" style={{ gridColumn: 'span 6' }}>
                  <label className="control-label">
                    Senha<span style={{ color: 'red' }}>*</span>
                  </label>
                  <input
                    type="password"
                    className="form-control"
                    maxLength={20}
                    autoComplete="new-password"
                    value={senha}
                    onChange={(e) => setSenha(e.target.value)}
                  />
                </div>
                <div className="form-group" style={{ gridColumn: 'span 6' }}>
                  <label className="control-label">
                    Confirmação Senha<span style={{ color: 'red' }}>*</span>
                  </label>
                  <input
                    type="password"
                    className="form-control"
                    maxLength={20}
                    autoComplete="new-password"
                    value={confirmacaoSenha}
                    onChange={(e) => setConfirmacaoSenha(e.target.value)}
                  />
                </div>
              </>
            ) : null}
            <div className="efetivo-filtros-actions" style={{ gridColumn: '1 / -1', justifyContent: 'flex-end' }}>
              <button type="button" className="btn btn-blue" onClick={() => goOperador('/colaborador/index')}>
                <i className="fa fa-arrow-left" aria-hidden />
                <span> VOLTAR</span>
              </button>
              {!readOnly ? (
                <button type="submit" className="btn btn-blue" style={{ marginLeft: 8 }} disabled={saving}>
                  <i className="fa fa-save" aria-hidden />
                  <span> SALVAR</span>
                </button>
              ) : null}
            </div>
          </form>
        ) : null}
      </section>
    </OperadorShell>
  )
}
