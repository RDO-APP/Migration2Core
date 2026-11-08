import { useCallback, useEffect, useState } from 'react'
import {
  deleteObraIndex,
  fetchObraIndexLista,
  selecionarObra,
  type ObraIndexItem,
} from '../api/obrasApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

export function ObraIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtroNome, setFiltroNome] = useState('')
  const [items, setItems] = useState<ObraIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<number | null>(null)

  const carregar = useCallback(async (descricao: string) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchObraIndexLista(descricao)
      setItems(data.items)
      setObraNome(data.obraNomeSessao || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar obras.'
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

  async function onEditar(item: ObraIndexItem) {
    setBusyId(item.idObra)
    try {
      await selecionarObra(item.idObra)
      goOperador(P3_NAV.toolbar.editarObra)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível abrir a obra.')
    } finally {
      setBusyId(null)
    }
  }

  async function onExcluir(item: ObraIndexItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.descricao}?`)) {
      return
    }
    setBusyId(item.idObra)
    try {
      await deleteObraIndex(item.idObra)
      showToast('success', 'Registro excluído com sucesso.')
      await carregar(filtroNome)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível excluir.')
    } finally {
      setBusyId(null)
    }
  }

  const canCriar = shell?.showNovaObra === true

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Obras</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: '1fr' }}>
          <div className="form-group">
            <label className="control-label">Nome</label>
            <input
              type="text"
              className="form-control"
              maxLength={100}
              value={filtroNome}
              onChange={(e) => setFiltroNome(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtroNome)
              }}
            />
          </div>
          <div className="efetivo-filtros-actions">
            <button
              type="button"
              className="btn btn-blue"
              disabled={searching}
              onClick={() => void carregar(filtroNome)}
            >
              <i className="fa fa-search" aria-hidden />
              <span> PESQUISAR</span>
            </button>
            {canCriar ? (
              <button
                type="button"
                className="btn btn-blue"
                style={{ marginLeft: 8 }}
                onClick={() => goOperador(P3_NAV.header.novaObraCadastro)}
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
          <div className="tabela table-responsive lista-tarefas">
            <table className="table table-striped table-responsive">
              <thead>
                <tr>
                  <th>Nome</th>
                  <th>Contratante</th>
                  <th>Contratada</th>
                  <th>Data Início</th>
                  <th>Data Conclusão</th>
                  <th>Local</th>
                  <th>Dias Decorridos</th>
                  <th colSpan={2} style={{ width: '12%' }}>
                    AÇÕES
                  </th>
                </tr>
              </thead>
              <tbody>
                {items.map((obra) => (
                  <tr key={obra.idObra}>
                    <td>{obra.descricao || '-'}</td>
                    <td>{obra.descricaoContratante || '-'}</td>
                    <td>{obra.descricaoContratada || '-'}</td>
                    <td>{obra.dataInicio || '-'}</td>
                    <td>{obra.dataConclusao || '-'}</td>
                    <td>{obra.cidadeEstado || '-'}</td>
                    <td>{obra.diasDecorridos}</td>
                    <td>
                      <button
                        type="button"
                        className="btn btn-simple btn-just-icon"
                        title="Editar"
                        disabled={busyId === obra.idObra}
                        onClick={() => void onEditar(obra)}
                      >
                        <i className="fa fa-edit" aria-hidden />
                      </button>
                    </td>
                    <td>
                      <button
                        type="button"
                        className="btn btn-simple btn-just-icon"
                        title="Excluir"
                        disabled={busyId === obra.idObra}
                        onClick={() => void onExcluir(obra)}
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
