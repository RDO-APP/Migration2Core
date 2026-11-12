import { useEffect, useState } from 'react'
import {
  fetchEmpresaCadastro,
  fetchEmpresaIndexMunicipios,
  saveEmpresaCadastro,
  type EmpresaCadastroForm,
  type EmpresaIndexLookup,
} from '../api/empresaApi'
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

export function EmpresaCadastroPage() {
  const { shell } = useShellContext()
  const id = idFromUrl()
  const visualizar = isVisualizar()
  const [form, setForm] = useState<EmpresaCadastroForm | null>(null)
  const [municipios, setMunicipios] = useState<EmpresaIndexLookup[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const data = await fetchEmpresaCadastro(id)
        if (cancelled) return
        setForm(data)
        setMunicipios(data.municipios)
      } catch (e: unknown) {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar empresa.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [id])

  const readOnly = visualizar || (form != null && !form.editavel)

  async function onChangeUf(idUf: number) {
    if (!form) return
    setForm({ ...form, idUf, idMunicipio: 0 })
    if (idUf <= 0) {
      setMunicipios([])
      return
    }
    try {
      setMunicipios(await fetchEmpresaIndexMunicipios(idUf))
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao carregar municípios.')
      setMunicipios([])
    }
  }

  async function onSave() {
    if (!form || readOnly) return
    setSaving(true)
    try {
      const result = await saveEmpresaCadastro({
        idEmpresa: form.idEmpresa,
        razaoSocial: form.razaoSocial,
        nomeFantasia: form.nomeFantasia,
        cnpj: form.cnpj,
        idRamo: form.idRamo,
        idSetor: form.idSetor,
        logradouro: form.logradouro,
        numeroEndereco: form.numeroEndereco,
        complemento: form.complemento,
        bairro: form.bairro,
        idMunicipio: form.idMunicipio,
        cep: form.cep,
        telefone: form.telefone,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador('/empresa/index')
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
          <h3>Empresa</h3>
        </div>
        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <p className="error">{error}</p> : null}
        {!loading && !error && form ? (
          <form
            className="panel efetivo-filtros"
            style={{ gridTemplateColumns: 'repeat(12, minmax(0, 1fr))' }}
            onSubmit={(e) => {
              e.preventDefault()
              void onSave()
            }}
          >
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">
                Razão Social<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoFocus
                disabled={readOnly}
                value={form.razaoSocial}
                onChange={(e) => setForm({ ...form, razaoSocial: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                CNPJ<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={18}
                disabled={readOnly}
                placeholder="00.000.000/0000-00"
                value={form.cnpj}
                onChange={(e) => setForm({ ...form, cnpj: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Nome Fantasia<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.nomeFantasia}
                onChange={(e) => setForm({ ...form, nomeFantasia: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Ramo Atividade<span style={{ color: 'red' }}>*</span>
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.idRamo}
                onChange={(e) => setForm({ ...form, idRamo: Number(e.target.value) || 0 })}
              >
                <option value={0}>Selecione...</option>
                {form.ramos.map((r) => (
                  <option key={r.id} value={r.id}>
                    {r.nome}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Setor<span style={{ color: 'red' }}>*</span>
              </label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.idSetor}
                onChange={(e) => setForm({ ...form, idSetor: Number(e.target.value) || 0 })}
              >
                <option value={0}>Selecione...</option>
                {form.setores.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.nome}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 8' }}>
              <label className="control-label">
                Logradouro<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.logradouro}
                onChange={(e) => setForm({ ...form, logradouro: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Número</label>
              <input
                type="text"
                className="form-control"
                maxLength={5}
                disabled={readOnly}
                value={form.numeroEndereco}
                onChange={(e) => setForm({ ...form, numeroEndereco: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Complemento</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
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
                maxLength={20}
                disabled={readOnly}
                value={form.bairro}
                onChange={(e) => setForm({ ...form, bairro: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                UF<span style={{ color: 'red' }}>*</span>
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
                Município<span style={{ color: 'red' }}>*</span>
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
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">CEP</label>
              <input
                type="text"
                className="form-control"
                maxLength={9}
                disabled={readOnly}
                value={form.cep}
                onChange={(e) => setForm({ ...form, cep: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">
                Telefone<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={14}
                disabled={readOnly}
                placeholder="(00)00000-0000"
                value={form.telefone}
                onChange={(e) => setForm({ ...form, telefone: e.target.value })}
              />
            </div>
            <div className="efetivo-filtros-actions" style={{ gridColumn: '1 / -1', justifyContent: 'flex-end' }}>
              <button type="button" className="btn btn-blue" onClick={() => goOperador('/empresa/index')}>
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
