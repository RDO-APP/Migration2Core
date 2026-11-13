import { useCallback, useEffect, useState } from 'react'
import {
  deleteParalizacaoIndex,
  fetchParalizacaoIndexBootstrap,
  fetchParalizacaoIndexLista,
  type ParalizacaoIndexFilter,
  type ParalizacaoIndexItem,
  type ParalizacaoIndexPermissions,
} from '../api/paralizacaoApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

const EMPTY_FILTRO: ParalizacaoIndexFilter = { descricao: '' }

const EMPTY_PERMS: ParalizacaoIndexPermissions = {
  showEditar: false,
  showDeletar: false,
  showNovo: false,
}

export function ParalizacaoIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtro, setFiltro] = useState<ParalizacaoIndexFilter>(EMPTY_FILTRO)
  const [perms, setPerms] = useState<ParalizacaoIndexPermissions>(EMPTY_PERMS)
  const [items, setItems] = useState<ParalizacaoIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)

  const carregar = useCallback(async (f: ParalizacaoIndexFilter) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchParalizacaoIndexLista(f)
      setItems(data.items)
      setObraNome(data.obraNomeSessao || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar códigos de paralização.'
      setError(msg)
      showToast('error', msg)
    } finally {
      setSearching(false)
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const boot = await fetchParalizacaoIndexBootstrap()
        if (cancelled) return
        setPerms(boot.permissions)
        setObraNome(boot.obraNomeSessao || undefined)
        await carregar(EMPTY_FILTRO)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar códigos de paralização.'
        setError(msg)
        showToast('error', msg)
        setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [carregar])

  function openCadastro(item: ParalizacaoIndexItem | null) {
    if (item) {
      goOperador(`/tarefa/paralizacoes/cadastro?codigo=${encodeURIComponent(item.codigo)}`)
      return
    }
    goOperador('/tarefa/paralizacoes/cadastro?modo=novo')
  }

  async function onExcluir(item: ParalizacaoIndexItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.descricao}?`)) {
      return
    }
    setBusyId(item.codigo)
    try {
      const result = await deleteParalizacaoIndex(item.codigo)
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível excluir.')
        return
      }
      showToast('success', 'Registro excluído com sucesso.')
      await carregar(filtro)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível excluir.')
    } finally {
      setBusyId(null)
    }
  }

  const showAcoes = perms.showEditar || perms.showDeletar

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Código de Paralizações</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: '1fr' }}>
          <div className="form-group">
            <label className="control-label">Nome</label>
            <input
              type="text"
              className="form-control"
              maxLength={100}
              autoFocus
              value={filtro.descricao}
              onChange={(e) => setFiltro((f) => ({ ...f, descricao: e.target.value }))}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtro)
              }}
            />
          </div>
          <div className="efetivo-filtros-actions">
            <button
              type="button"
              className="btn btn-blue"
              disabled={searching}
              onClick={() => void carregar(filtro)}
            >
              <i className="fa fa-search" aria-hidden />
              <span> PESQUISAR</span>
            </button>
            {perms.showNovo ? (
              <button
                type="button"
                className="btn btn-blue"
                style={{ marginLeft: 8 }}
                onClick={() => openCadastro(null)}
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
                  <th style={{ width: '10%' }}>CÓDIGO</th>
                  <th>DESCRIÇÃO</th>
                  {showAcoes ? (
                    <th colSpan={2} style={{ width: '15%' }}>
                      AÇÕES
                    </th>
                  ) : null}
                </tr>
              </thead>
              <tbody>
                {items.map((item) => (
                  <tr key={item.codigo}>
                    <td>{item.codigo}</td>
                    <td>{item.descricao}</td>
                    {showAcoes ? (
                      <>
                        <td>
                          {item.editavel ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Editar"
                              onClick={() => openCadastro(item)}
                            >
                              <i className="fa fa-edit" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {item.excluivel ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Excluir"
                              disabled={busyId === item.codigo}
                              onClick={() => void onExcluir(item)}
                            >
                              <i className="fa fa-trash-o" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                      </>
                    ) : null}
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
