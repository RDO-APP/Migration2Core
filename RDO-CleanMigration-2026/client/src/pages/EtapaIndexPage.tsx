import { useCallback, useEffect, useState } from 'react'
import { deleteEtapa, fetchEtapaLista, type EtapaListItem } from '../api/etapaApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

export function EtapaIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtroTitulo, setFiltroTitulo] = useState('')
  const [items, setItems] = useState<EtapaListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [deletingId, setDeletingId] = useState<number | null>(null)

  const carregar = useCallback(async (titulo: string) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchEtapaLista(titulo)
      setItems(data.items)
      setObraNome(data.obraNome || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar etapas.'
      setError(msg)
      showToast('error', msg)
    } finally {
      setSearching(false)
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void carregar('')
  }, [carregar])

  async function onExcluir(item: EtapaListItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.titulo}?`)) {
      return
    }
    setDeletingId(item.id)
    try {
      const result = await deleteEtapa(item.id)
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível excluir.')
        return
      }
      showToast('success', 'Registro excluído com sucesso.')
      await carregar(filtroTitulo)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível excluir.')
    } finally {
      setDeletingId(null)
    }
  }

  const canCriar = shell?.showCriarNovaEtapa === true

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Etapas</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: '1fr' }}>
          <div className="form-group">
            <label className="control-label">Nome</label>
            <input
              type="text"
              className="form-control"
              maxLength={100}
              value={filtroTitulo}
              onChange={(e) => setFiltroTitulo(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtroTitulo)
              }}
            />
          </div>
          <div className="efetivo-filtros-actions">
            <button
              type="button"
              className="btn btn-blue"
              disabled={searching}
              onClick={() => void carregar(filtroTitulo)}
            >
              <i className="fa fa-search" aria-hidden />
              <span> PESQUISAR</span>
            </button>
            {canCriar ? (
              <button
                type="button"
                className="btn btn-blue"
                style={{ marginLeft: 8 }}
                onClick={() => goOperador('/Etapa/Cadastro')}
              >
                <i className="fa fa-plus" aria-hidden />
                <span> NOVO</span>
              </button>
            ) : null}
          </div>
        </div>

        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <p className="error">{error}</p> : null}

        {!loading && !error && items.length === 0 ? (
          <label className="col-xs-12 no-padding efetivo-empty">Nenhum registro encontrado.</label>
        ) : null}

        {!loading && items.length > 0 ? (
          <div className="tabela table-responsive">
            <table className="table table-striped table-responsive">
              <thead>
                <tr>
                  <th style={{ width: '10%' }}>ORDEM</th>
                  <th>ETAPA</th>
                  <th colSpan={2} style={{ width: '15%' }}>
                    AÇÕES
                  </th>
                </tr>
              </thead>
              <tbody>
                {items.map((etapa) => (
                  <tr key={etapa.id}>
                    <td>{etapa.ordem}</td>
                    <td>{etapa.titulo}</td>
                    <td>
                      <button
                        type="button"
                        className="btn btn-simple btn-just-icon"
                        title="Editar"
                        onClick={() => goOperador(`/Etapa/Cadastro?id=${etapa.id}`)}
                      >
                        <i className="fa fa-edit" aria-hidden />
                      </button>
                    </td>
                    <td>
                      <button
                        type="button"
                        className="btn btn-simple btn-just-icon"
                        title="Excluir"
                        disabled={deletingId === etapa.id}
                        onClick={() => void onExcluir(etapa)}
                      >
                        <i className="fa fa-trash-o" aria-hidden />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
      </section>
    </OperadorShell>
  )
}
