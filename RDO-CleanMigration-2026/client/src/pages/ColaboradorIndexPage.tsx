import { useCallback, useEffect, useState } from 'react'
import {
  deleteColaboradorIndex,
  fetchColaboradorIndexBootstrap,
  fetchColaboradorIndexLista,
  fetchColaboradorIndexMunicipios,
  type ColaboradorIndexFilter,
  type ColaboradorIndexItem,
  type ColaboradorIndexLookup,
  type ColaboradorIndexPermissions,
} from '../api/colaboradorApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

const EMPTY_FILTRO: ColaboradorIndexFilter = {
  nome: '',
  cpf: '',
  sexo: 'S',
  email: '',
  crea: '',
  idUf: 0,
  idMunicipio: 0,
  idCargo: 0,
  idGrupo: 0,
  dataContratacao: '',
}

const EMPTY_PERMS: ColaboradorIndexPermissions = {
  showVisualizar: false,
  showEditar: false,
  showDeletar: false,
  showNovo: false,
}

export function ColaboradorIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtro, setFiltro] = useState<ColaboradorIndexFilter>(EMPTY_FILTRO)
  const [ufs, setUfs] = useState<ColaboradorIndexLookup[]>([])
  const [municipios, setMunicipios] = useState<ColaboradorIndexLookup[]>([])
  const [cargos, setCargos] = useState<ColaboradorIndexLookup[]>([])
  const [grupos, setGrupos] = useState<ColaboradorIndexLookup[]>([])
  const [perms, setPerms] = useState<ColaboradorIndexPermissions>(EMPTY_PERMS)
  const [items, setItems] = useState<ColaboradorIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<number | null>(null)

  const carregar = useCallback(async (f: ColaboradorIndexFilter) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchColaboradorIndexLista(f)
      setItems(data.items)
      setObraNome(data.obraNomeSessao || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar colaboradores.'
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
        const boot = await fetchColaboradorIndexBootstrap()
        if (cancelled) return
        setUfs(boot.ufs)
        setCargos(boot.cargos)
        setGrupos(boot.grupos)
        setPerms(boot.permissions)
        setObraNome(boot.obraNomeSessao || undefined)
        await carregar(EMPTY_FILTRO)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar colaboradores.'
        setError(msg)
        showToast('error', msg)
        setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [carregar])

  async function onChangeUf(idUf: number) {
    setFiltro((f) => ({ ...f, idUf, idMunicipio: 0 }))
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

  function openCadastro(item: ColaboradorIndexItem | null, modo: 'novo' | 'editar' | 'visualizar') {
    const q = new URLSearchParams()
    if (item) q.set('id', String(item.idColaborador))
    if (modo === 'visualizar') q.set('modo', 'visualizar')
    if (modo === 'novo') q.set('modo', 'novo')
    const qs = q.toString()
    goOperador(`/colaborador/cadastro${qs ? `?${qs}` : ''}`)
  }

  async function onExcluir(item: ColaboradorIndexItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.nome}?`)) {
      return
    }
    setBusyId(item.idColaborador)
    try {
      const result = await deleteColaboradorIndex(item.idColaborador)
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

  const showAcoes =
    perms.showVisualizar ||
    (perms.showEditar && items.some((i) => i.editavel)) ||
    (perms.showDeletar && items.some((i) => i.excluivel))

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Colaborador</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: 'repeat(3, minmax(0, 1fr))' }}>
          <div className="form-group">
            <label className="control-label">Nome</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.nome}
              onChange={(e) => setFiltro((f) => ({ ...f, nome: e.target.value }))}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtro)
              }}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Cargo</label>
            <select
              className="form-control"
              value={filtro.idCargo}
              onChange={(e) => setFiltro((f) => ({ ...f, idCargo: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              {cargos.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">CPF</label>
            <input
              type="text"
              className="form-control"
              maxLength={14}
              placeholder="000.000.000-00"
              value={filtro.cpf}
              onChange={(e) => setFiltro((f) => ({ ...f, cpf: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Sexo</label>
            <select
              className="form-control"
              value={filtro.sexo}
              onChange={(e) => setFiltro((f) => ({ ...f, sexo: e.target.value }))}
            >
              <option value="S">Selecione...</option>
              <option value="M">Masculino</option>
              <option value="F">Feminino</option>
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Perfil (Grupo)</label>
            <select
              className="form-control"
              value={filtro.idGrupo}
              onChange={(e) => setFiltro((f) => ({ ...f, idGrupo: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              {grupos.map((g) => (
                <option key={g.id} value={g.id}>
                  {g.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">E-mail</label>
            <input
              type="text"
              className="form-control"
              value={filtro.email}
              onChange={(e) => setFiltro((f) => ({ ...f, email: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">CREA</label>
            <input
              type="text"
              className="form-control"
              value={filtro.crea}
              onChange={(e) => setFiltro((f) => ({ ...f, crea: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">UF</label>
            <select
              className="form-control"
              value={filtro.idUf}
              onChange={(e) => void onChangeUf(Number(e.target.value) || 0)}
            >
              <option value={0}>Selecione...</option>
              {ufs.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Município</label>
            <select
              className="form-control"
              value={filtro.idMunicipio}
              onChange={(e) => setFiltro((f) => ({ ...f, idMunicipio: Number(e.target.value) || 0 }))}
              disabled={filtro.idUf <= 0}
            >
              <option value={0}>Selecione...</option>
              {municipios.map((m) => (
                <option key={m.id} value={m.id}>
                  {m.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Data da Contratação</label>
            <input
              type="text"
              className="form-control"
              maxLength={10}
              placeholder="dd/mm/aaaa"
              value={filtro.dataContratacao}
              onChange={(e) => setFiltro((f) => ({ ...f, dataContratacao: e.target.value }))}
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
                  <th>Nome</th>
                  <th>Cargo</th>
                  <th>Telefone</th>
                  <th>E-mail</th>
                  <th>Perfil</th>
                  {showAcoes ? (
                    <th colSpan={3} style={{ width: '15%' }}>
                      AÇÕES
                    </th>
                  ) : null}
                </tr>
              </thead>
              <tbody>
                {items.map((col) => (
                  <tr key={col.idColaborador}>
                    <td>{col.nome || '-'}</td>
                    <td>{col.descricaoCargo || '-'}</td>
                    <td>{col.telefonePrincipal || '-'}</td>
                    <td>{col.email || '-'}</td>
                    <td>{col.descricaoGrupo || '-'}</td>
                    {showAcoes ? (
                      <>
                        <td>
                          {perms.showVisualizar ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Visualizar"
                              onClick={() => openCadastro(col, 'visualizar')}
                            >
                              <i className="fa fa-eye" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {perms.showEditar && col.editavel ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Editar"
                              onClick={() => openCadastro(col, 'editar')}
                            >
                              <i className="fa fa-edit" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {perms.showDeletar && col.excluivel ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Excluir"
                              disabled={busyId === col.idColaborador}
                              onClick={() => void onExcluir(col)}
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
