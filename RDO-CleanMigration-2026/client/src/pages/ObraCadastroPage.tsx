import { useEffect, useState } from 'react'
import { fetchObraCadastro, saveObraCadastro, type ObraCadastro } from '../api/obraCadastroApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import '../rdo-cadastro.css'
import '../tarefa-cadastro.css'

type FormState = {
  descricao: string
  dataInicio: string
  dataPrevisaoFim: string
  logradouro: string
  numero: string
  bairro: string
  cep: string
  areaTotal: string
  areaConstruida: string
  cidadeEstado: string
  finalizada: boolean
}

function toForm(d: ObraCadastro): FormState {
  return {
    descricao: d.descricao ?? '',
    dataInicio: d.dataInicio ?? '',
    dataPrevisaoFim: d.dataPrevisaoFim ?? '',
    logradouro: d.logradouro ?? '',
    numero: d.numero ?? '',
    bairro: d.bairro ?? '',
    cep: d.cep ?? '',
    areaTotal: d.areaTotal != null ? String(d.areaTotal) : '',
    areaConstruida: d.areaConstruida != null ? String(d.areaConstruida) : '',
    cidadeEstado: d.cidadeEstado ?? '',
    finalizada: d.finalizada,
  }
}

function parseOptInt(v: string): number | null {
  const t = v.trim()
  if (!t) return null
  const n = Number(t)
  return Number.isFinite(n) ? Math.trunc(n) : null
}

export function ObraCadastroPage() {
  const { shell } = useShellContext()
  const [form, setForm] = useState<FormState | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    fetchObraCadastro()
      .then((d) => {
        if (!cancelled) setForm(toForm(d))
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar obra.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  function setField<K extends keyof FormState>(key: K, value: FormState[K]) {
    setForm((prev) => (prev ? { ...prev, [key]: value } : prev))
  }

  async function onSave() {
    if (!form) return
    if (form.finalizada) {
      showToast('error', 'Obra finalizada — edição bloqueada.')
      return
    }
    const descricao = form.descricao.trim()
    if (descricao.length < 3) {
      showToast('error', 'Informe o nome da obra (mín. 3 caracteres).')
      return
    }
    if (!form.dataInicio.trim()) {
      showToast('error', 'A Data inicial deve ser preenchida.')
      return
    }
    setSaving(true)
    try {
      const result = await saveObraCadastro({
        descricao,
        dataInicio: form.dataInicio.trim(),
        dataPrevisaoFim: form.dataPrevisaoFim.trim(),
        logradouro: form.logradouro.trim(),
        numero: form.numero.trim(),
        bairro: form.bairro.trim(),
        cep: form.cep.trim(),
        areaTotal: parseOptInt(form.areaTotal),
        areaConstruida: parseOptInt(form.areaConstruida),
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador(P3_NAV.header.tarefaCards)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  const disabled = !!form?.finalizada

  return (
    <OperadorShell variant="cards" obraNome={form?.descricao || shell?.obraNome} shell={shell}>
      <section className="rdo-cadastro-page tarefa-cadastro-page">
        <div className="panel-heading">
          <h3>Obra</h3>
        </div>
        {loading ? (
          <p className="muted">Carregando…</p>
        ) : error ? (
          <p className="error">{error}</p>
        ) : form ? (
          <>
            {form.finalizada ? (
              <p className="muted">Obra finalizada — campos somente leitura.</p>
            ) : null}
            <form
              className="panel"
              onSubmit={(e) => {
                e.preventDefault()
                void onSave()
              }}
            >
              <div className="row g-3">
                <div className="col-12">
                  <div className="form-group">
                    <label className="control-label">
                      Nome da Obra<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.descricao}
                      onChange={(e) => setField('descricao', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-6">
                  <div className="form-group">
                    <label className="control-label">
                      Data inicial<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="dd/mm/aaaa"
                      maxLength={10}
                      disabled={disabled}
                      value={form.dataInicio}
                      onChange={(e) => setField('dataInicio', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-6">
                  <div className="form-group">
                    <label className="control-label">Data previsão final</label>
                    <input
                      type="text"
                      className="form-control"
                      placeholder="dd/mm/aaaa"
                      maxLength={10}
                      disabled={disabled}
                      value={form.dataPrevisaoFim}
                      onChange={(e) => setField('dataPrevisaoFim', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-12">
                  <div className="form-group">
                    <label className="control-label">Logradouro</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.logradouro}
                      onChange={(e) => setField('logradouro', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="form-group">
                    <label className="control-label">Número</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={5}
                      disabled={disabled}
                      value={form.numero}
                      onChange={(e) => setField('numero', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="form-group">
                    <label className="control-label">Bairro</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.bairro}
                      onChange={(e) => setField('bairro', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="form-group">
                    <label className="control-label">CEP</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={10}
                      disabled={disabled}
                      value={form.cep}
                      onChange={(e) => setField('cep', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-6">
                  <div className="form-group">
                    <label className="control-label">Cidade/UF</label>
                    <input type="text" className="form-control" disabled value={form.cidadeEstado} readOnly />
                  </div>
                </div>
                <div className="col-md-3">
                  <div className="form-group">
                    <label className="control-label">Área total</label>
                    <input
                      type="text"
                      className="form-control"
                      inputMode="numeric"
                      disabled={disabled}
                      value={form.areaTotal}
                      onChange={(e) => setField('areaTotal', e.target.value.replace(/\D/g, '').slice(0, 9))}
                    />
                  </div>
                </div>
                <div className="col-md-3">
                  <div className="form-group">
                    <label className="control-label">Área construída</label>
                    <input
                      type="text"
                      className="form-control"
                      inputMode="numeric"
                      disabled={disabled}
                      value={form.areaConstruida}
                      onChange={(e) =>
                        setField('areaConstruida', e.target.value.replace(/\D/g, '').slice(0, 9))
                      }
                    />
                  </div>
                </div>
              </div>
            </form>
            <div className="col-xs-12 no-padding cadastro-form-actions">
              <button type="button" className="btn btn-blue" onClick={() => window.history.back()}>
                <i className="fa fa-arrow-left" aria-hidden />
                <span>Voltar</span>
              </button>
              <button
                type="button"
                className="btn btn-blue"
                disabled={saving || disabled}
                onClick={() => void onSave()}
              >
                <i className="fa fa-check" aria-hidden />
                <span>SALVAR</span>
              </button>
            </div>
          </>
        ) : null}
      </section>
    </OperadorShell>
  )
}
