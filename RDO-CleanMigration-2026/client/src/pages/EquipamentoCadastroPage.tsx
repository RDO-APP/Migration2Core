import { useEffect, useState } from 'react'
import {
  fetchEquipamentoCadastro,
  saveEquipamentoCadastro,
  type EquipamentoCadastroForm,
} from '../api/equipamentoApi'
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

const EMPTY: EquipamentoCadastroForm = {
  idEquipamento: 0,
  idObraEquipamento: 0,
  tipoEquipamento: '',
  descricao: '',
  marca: '',
  modelo: '',
  tipoAquisicao: 'S',
  dataAquisicao: '',
  fabricanteFornecedor: '',
  contato: '',
  telefone: '',
  podeSalvar: true,
  obraNomeSessao: '',
}

export function EquipamentoCadastroPage() {
  const { shell } = useShellContext()
  const id = idFromUrl()
  const visualizar = isVisualizar()
  const [form, setForm] = useState<EquipamentoCadastroForm>(EMPTY)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const data = await fetchEquipamentoCadastro(id)
        if (cancelled) return
        setForm(data)
      } catch (e: unknown) {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar equipamento.')
      } finally {
        if (!cancelled) setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [id])

  const readOnly = visualizar || !form.podeSalvar

  async function onSave() {
    if (readOnly) return
    setSaving(true)
    try {
      const result = await saveEquipamentoCadastro({
        idEquipamento: form.idEquipamento,
        tipoEquipamento: form.tipoEquipamento,
        descricao: form.descricao,
        marca: form.marca,
        modelo: form.modelo,
        tipoAquisicao: form.tipoAquisicao,
        dataAquisicao: form.dataAquisicao,
        fabricanteFornecedor: form.fabricanteFornecedor,
        contato: form.contato,
        telefone: form.telefone,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador('/equipamentos/index')
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
          <h3>Equipamentos</h3>
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
            <div className="form-group" style={{ gridColumn: 'span 3' }}>
              <label className="control-label">
                Tipo de Equipamento<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.tipoEquipamento}
                onChange={(e) => setForm({ ...form, tipoEquipamento: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 9' }}>
              <label className="control-label">
                Descrição<span style={{ color: 'red' }}>*</span>
              </label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                autoFocus
                disabled={readOnly}
                value={form.descricao}
                onChange={(e) => setForm({ ...form, descricao: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Marca</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.marca}
                onChange={(e) => setForm({ ...form, marca: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Modelo</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.modelo}
                onChange={(e) => setForm({ ...form, modelo: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 4' }}>
              <label className="control-label">Tipo de Aquisição</label>
              <select
                className="form-control"
                disabled={readOnly}
                value={form.tipoAquisicao}
                onChange={(e) => setForm({ ...form, tipoAquisicao: e.target.value })}
              >
                <option value="S">Selecione...</option>
                <option value="A">Aluguel</option>
                <option value="C">Compra</option>
              </select>
            </div>
            <div className="form-group" style={{ gridColumn: 'span 3' }}>
              <label className="control-label">Data da Aquisição</label>
              <input
                type="text"
                className="form-control"
                maxLength={10}
                placeholder="dd/mm/aaaa"
                disabled={readOnly}
                value={form.dataAquisicao}
                onChange={(e) => setForm({ ...form, dataAquisicao: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 3' }}>
              <label className="control-label">Fornecedor/Fabricante</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.fabricanteFornecedor}
                onChange={(e) => setForm({ ...form, fabricanteFornecedor: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 3' }}>
              <label className="control-label">Contato</label>
              <input
                type="text"
                className="form-control"
                maxLength={50}
                disabled={readOnly}
                value={form.contato}
                onChange={(e) => setForm({ ...form, contato: e.target.value })}
              />
            </div>
            <div className="form-group" style={{ gridColumn: 'span 3' }}>
              <label className="control-label">Telefone</label>
              <input
                type="text"
                className="form-control"
                maxLength={15}
                disabled={readOnly}
                value={form.telefone}
                onChange={(e) => setForm({ ...form, telefone: e.target.value })}
              />
            </div>
            <div className="efetivo-filtros-actions" style={{ gridColumn: '1 / -1', justifyContent: 'flex-end' }}>
              <button type="button" className="btn btn-blue" onClick={() => goOperador('/equipamentos/index')}>
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
