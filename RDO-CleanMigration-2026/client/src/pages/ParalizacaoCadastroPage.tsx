import { useEffect, useState } from 'react'
import {
  fetchParalizacaoCadastro,
  saveParalizacaoCadastro,
  type ParalizacaoCadastroForm,
} from '../api/paralizacaoApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'
import '../rdo-cadastro.css'

function codigoFromUrl(): string {
  return (new URLSearchParams(window.location.search).get('codigo') || '').trim()
}

const EMPTY: ParalizacaoCadastroForm = {
  codigo: '',
  descricao: '',
  update: false,
  podeSalvar: true,
  obraNomeSessao: '',
}

export function ParalizacaoCadastroPage() {
  const { shell } = useShellContext()
  const codigoUrl = codigoFromUrl()
  const [form, setForm] = useState<ParalizacaoCadastroForm>(EMPTY)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const data = await fetchParalizacaoCadastro(codigoUrl)
        if (cancelled) return
        setForm(data)
      } catch (e: unknown) {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar código de paralização.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [codigoUrl])

  const readOnly = !form.podeSalvar
  const codigoReadOnly = form.update || readOnly

  async function onSave() {
    if (readOnly) return
    setSaving(true)
    try {
      const result = await saveParalizacaoCadastro({
        codigo: form.codigo,
        descricao: form.descricao,
        update: form.update,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador('/tarefa/paralizacoes/index')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <OperadorShell variant="cards" obraNome={form.obraNomeSessao || shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page rdo-cadastro-page">
        <div className="panel-heading">
          <h3>Código de Paralizações</h3>
        </div>
        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <p className="error">{error}</p> : null}
        {!loading && !error ? (
          <form
            className="panel efetivo-filtros"
            style={{ gridTemplateColumns: 'repeat(12, minmax(0, 1fr))' }}
            onSubmit={(e) => {
              e.preventDefault()
              void onSave()
            }}
          >
            <div className="form-group" style={{ gridColumn: 'span 2' }}>
              <label className="control-label">
                Código<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                style={{ textTransform: 'uppercase' }}
                maxLength={3}
                readOnly={codigoReadOnly}
                value={form.codigo}
                onChange={(e) =>
                  setForm((f) => ({ ...f, codigo: e.target.value.toUpperCase().slice(0, 3) }))
                }
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 10' }}>
              <label className="control-label">
                Descrição<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={100}
                readOnly={readOnly}
                value={form.descricao}
                onChange={(e) => setForm((f) => ({ ...f, descricao: e.target.value }))}
              />
            </div>
            <div className="efetivo-filtros-actions" style={{ gridColumn: '1 / -1' }}>
              <button
                type="button"
                className="btn btn-blue"
                onClick={() => goOperador('/tarefa/paralizacoes/index')}
              >
                <i className="fa fa-arrow-left" aria-hidden />
                <span> Voltar</span>
              </button>
              {!readOnly ? (
                <button type="submit" className="btn btn-blue" style={{ marginLeft: 8 }} disabled={saving}>
                  <i className="icon-check" aria-hidden />
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
