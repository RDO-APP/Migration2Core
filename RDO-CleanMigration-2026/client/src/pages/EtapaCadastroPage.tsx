import { useEffect, useState } from 'react'
import { fetchEtapaCadastroBlank, saveEtapaCadastro } from '../api/etapaApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import '../rdo-cadastro.css'
import '../tarefa-cadastro.css'

function idFromUrl(): number | undefined {
  const raw = new URLSearchParams(window.location.search).get('id')
  const n = raw ? Number(raw) : NaN
  return Number.isFinite(n) && n > 0 ? n : undefined
}

export function EtapaCadastroPage() {
  const { shell } = useShellContext()
  const editId = idFromUrl()
  const [titulo, setTitulo] = useState('')
  const [ordem, setOrdem] = useState('')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    fetchEtapaCadastroBlank(editId)
      .then((b) => {
        if (cancelled) return
        if (b.titulo) setTitulo(b.titulo)
        setOrdem(String(b.ordemSugerida || ''))
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [editId])

  async function onSave() {
    const nome = titulo.trim()
    if (!nome) {
      showToast('error', 'O Nome deve ser preenchido')
      return
    }
    const n = Number(ordem)
    if (!Number.isFinite(n) || n <= 0) {
      showToast('error', 'O Nº Ordem deve ser preenchido.')
      return
    }
    setSaving(true)
    try {
      const result = await saveEtapaCadastro({
        id: editId,
        titulo: nome,
        ordem: n,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador('/Etapa/Index')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <OperadorShell variant="cards" obraNome={shell?.obraNome} shell={shell}>
      <section className="rdo-cadastro-page tarefa-cadastro-page">
        <div className="panel-heading">
          <h3>Etapa</h3>
        </div>
        {loading ? (
          <p className="muted">Carregando…</p>
        ) : error ? (
          <p className="error">{error}</p>
        ) : (
          <>
            <form
              className="panel"
              onSubmit={(e) => {
                e.preventDefault()
                void onSave()
              }}
            >
              <div className="row g-3">
                <div className="col-lg-10 col-md-8 col-sm-6">
                  <div className="form-group">
                    <label className="control-label">
                      Nome<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={100}
                      value={titulo}
                      onChange={(e) => setTitulo(e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-lg-2 col-md-4 col-sm-6">
                  <div className="form-group">
                    <label className="control-label">
                      Nº Ordem<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={5}
                      inputMode="numeric"
                      value={ordem}
                      onChange={(e) => setOrdem(e.target.value.replace(/\D/g, '').slice(0, 5))}
                    />
                  </div>
                </div>
              </div>
            </form>
            <div className="col-xs-12 no-padding cadastro-form-actions">
              <button type="button" className="btn btn-blue" onClick={() => goOperador('/Etapa/Index')}>
                <i className="fa fa-arrow-left" aria-hidden />
                <span>Voltar</span>
              </button>
              <button type="button" className="btn btn-blue" disabled={saving} onClick={() => void onSave()}>
                <i className="fa fa-check" aria-hidden />
                <span>SALVAR</span>
              </button>
            </div>
          </>
        )}
      </section>
    </OperadorShell>
  )
}
