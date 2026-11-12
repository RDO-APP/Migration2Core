import { useCallback, useEffect, useState } from 'react'
import {
  deleteEquipamentoIndex,
  fetchEquipamentoIndexBootstrap,
  fetchEquipamentoIndexLista,
  type EquipamentoIndexFilter,
  type EquipamentoIndexItem,
  type EquipamentoIndexPermissions,
} from '../api/equipamentoApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

const EMPTY_FILTRO: EquipamentoIndexFilter = {
  tipoEquipamento: '',
  descricao: '',
  marca: '',
  modelo: '',
  tipoAquisicao: 'S',
  fabricanteFornecedor: '',
}

const EMPTY_PERMS: EquipamentoIndexPermissions = {
  showVisualizar: false,
  showEditar: false,
  showDeletar: false,
  showNovo: false,
}

export function EquipamentoIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtro, setFiltro] = useState<EquipamentoIndexFilter>(EMPTY_FILTRO)
  const [perms, setPerms] = useState<EquipamentoIndexPermissions>(EMPTY_PERMS)
  const [items, setItems] = useState<EquipamentoIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<number | null>(null)

  const carregar = useCallback(async (f: EquipamentoIndexFilter) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchEquipamentoIndexLista(f)
      setItems(data.items)
      setObraNome(data.obraNomeSessao || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar equipamentos.'
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
        const boot = await fetchEquipamentoIndexBootstrap()
        if (cancelled) return
        setPerms(boot.permissions)
        setObraNome(boot.obraNomeSessao || undefined)
        await carregar(EMPTY_FILTRO)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar equipamentos.'
        setError(msg)
        showToast('error', msg)
        setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [carregar])

  function openCadastro(item: EquipamentoIndexItem | null, modo: 'novo' | 'editar' | 'visualizar') {
    const q = new URLSearchParams()
    if (item) q.set('id', String(item.idEquipamento))
    if (modo === 'visualizar') q.set('modo', 'visualizar')
    if (modo === 'novo') q.set('modo', 'novo')
    const qs = q.toString()
    goOperador(`/equipamentos/cadastro${qs ? `?${qs}` : ''}`)
  }

  async function onExcluir(item: EquipamentoIndexItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.descricao}?`)) {
      return
    }
    setBusyId(item.idEquipamento)
    try {
      const result = await deleteEquipamentoIndex(item.idEquipamento)
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

  const showAcoes = perms.showVisualizar || perms.showEditar || perms.showDeletar

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Equipamentos</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: 'repeat(3, minmax(0, 1fr))' }}>
          <div className="form-group">
            <label className="control-label">Tipo de Equipamento</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.tipoEquipamento}
              onChange={(e) => setFiltro((f) => ({ ...f, tipoEquipamento: e.target.value }))}
            />
          </div>
          <div className="form-group" style={{ gridColumn: 'span 2' }}>
            <label className="control-label">Descrição</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              autoFocus
              value={filtro.descricao}
              onChange={(e) => setFiltro((f) => ({ ...f, descricao: e.target.value }))}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtro)
              }}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Marca</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.marca}
              onChange={(e) => setFiltro((f) => ({ ...f, marca: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Modelo</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.modelo}
              onChange={(e) => setFiltro((f) => ({ ...f, modelo: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Tipo de Aquisição</label>
            <select
              className="form-control"
              value={filtro.tipoAquisicao}
              onChange={(e) => setFiltro((f) => ({ ...f, tipoAquisicao: e.target.value }))}
            >
              <option value="S">Selecione...</option>
              <option value="A">Aluguel</option>
              <option value="C">Compra</option>
            </select>
          </div>
          <div className="form-group" style={{ gridColumn: 'span 2' }}>
            <label className="control-label">Fornecedor/Fabricante</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.fabricanteFornecedor}
              onChange={(e) => setFiltro((f) => ({ ...f, fabricanteFornecedor: e.target.value }))}
            />
          </div>
          <div className="efetivo-filtros-actions" style={{ gridColumn: '1 / -1' }}>
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
                onClick={() => openCadastro(null, 'novo')}
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
                  <th>TIPO DE EQUIPAMENTO</th>
                  <th>DESCRIÇÃO</th>
                  <th>FABRICANTE / FORNECEDOR</th>
                  <th>CONTATO</th>
                  <th>TELEFONE</th>
                  {showAcoes ? (
                    <th colSpan={3} style={{ width: '15%' }}>
                      AÇÕES
                    </th>
                  ) : null}
                </tr>
              </thead>
              <tbody>
                {items.map((eq) => (
                  <tr key={eq.idEquipamento}>
                    <td>{eq.tipoEquipamento || '-'}</td>
                    <td>{eq.descricao || '-'}</td>
                    <td>{eq.fabricanteFornecedor || '-'}</td>
                    <td>{eq.contato || '-'}</td>
                    <td>{eq.telefone || '-'}</td>
                    {showAcoes ? (
                      <>
                        <td>
                          {perms.showVisualizar ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Visualizar"
                              onClick={() => openCadastro(eq, 'visualizar')}
                            >
                              <i className="fa fa-eye" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {perms.showEditar ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Editar"
                              onClick={() => openCadastro(eq, 'editar')}
                            >
                              <i className="fa fa-edit" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {perms.showDeletar ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Excluir"
                              disabled={busyId === eq.idEquipamento}
                              onClick={() => void onExcluir(eq)}
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
