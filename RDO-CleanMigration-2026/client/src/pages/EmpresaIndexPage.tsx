import { useCallback, useEffect, useState } from 'react'
import {
  fetchEmpresaIndexBootstrap,
  fetchEmpresaIndexLista,
  fetchEmpresaIndexMunicipios,
  maskPhone,
  type EmpresaIndexFilter,
  type EmpresaIndexItem,
  type EmpresaIndexLookup,
  type EmpresaIndexPermissions,
} from '../api/empresaApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

const EMPTY_FILTRO: EmpresaIndexFilter = {
  razaoSocial: '',
  cnpj: '',
  idUf: 0,
  idMunicipio: 0,
  idRamo: 0,
  idSetor: 0,
}

const EMPTY_PERMS: EmpresaIndexPermissions = {
  showVisualizar: false,
}

export function EmpresaIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtro, setFiltro] = useState<EmpresaIndexFilter>(EMPTY_FILTRO)
  const [ufs, setUfs] = useState<EmpresaIndexLookup[]>([])
  const [municipios, setMunicipios] = useState<EmpresaIndexLookup[]>([])
  const [ramos, setRamos] = useState<EmpresaIndexLookup[]>([])
  const [setores, setSetores] = useState<EmpresaIndexLookup[]>([])
  const [perms, setPerms] = useState<EmpresaIndexPermissions>(EMPTY_PERMS)
  const [items, setItems] = useState<EmpresaIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const carregar = useCallback(async (f: EmpresaIndexFilter) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchEmpresaIndexLista(f)
      setItems(data.items)
      setObraNome(data.obraNomeSessao || undefined)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar empresas.'
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
        const boot = await fetchEmpresaIndexBootstrap()
        if (cancelled) return
        setUfs(boot.ufs)
        setRamos(boot.ramos)
        setSetores(boot.setores)
        setPerms(boot.permissions)
        setObraNome(boot.obraNomeSessao || undefined)
        await carregar(EMPTY_FILTRO)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar empresas.'
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
      setMunicipios(await fetchEmpresaIndexMunicipios(idUf))
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao carregar municípios.')
      setMunicipios([])
    }
  }

  function openCadastro(item: EmpresaIndexItem, modo: 'editar' | 'visualizar') {
    const q = new URLSearchParams()
    q.set('id', String(item.idEmpresa))
    if (modo === 'visualizar') q.set('modo', 'visualizar')
    goOperador(`/empresa/cadastro?${q.toString()}`)
  }

  const showAcoes = perms.showVisualizar || items.some((i) => i.editavel)

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Empresa</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: 'repeat(3, minmax(0, 1fr))' }}>
          <div className="form-group">
            <label className="control-label">Razão Social</label>
            <input
              type="text"
              className="form-control"
              maxLength={200}
              autoFocus
              value={filtro.razaoSocial}
              onChange={(e) => setFiltro((f) => ({ ...f, razaoSocial: e.target.value }))}
              onKeyDown={(e) => {
                if (e.key === 'Enter') void carregar(filtro)
              }}
            />
          </div>
          <div className="form-group">
            <label className="control-label">CNPJ</label>
            <input
              type="text"
              className="form-control"
              maxLength={18}
              placeholder="00.000.000/0000-00"
              value={filtro.cnpj}
              onChange={(e) => setFiltro((f) => ({ ...f, cnpj: e.target.value }))}
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
            <label className="control-label">Ramo Atividade</label>
            <select
              className="form-control"
              value={filtro.idRamo}
              onChange={(e) => setFiltro((f) => ({ ...f, idRamo: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              {ramos.map((r) => (
                <option key={r.id} value={r.id}>
                  {r.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Setor</label>
            <select
              className="form-control"
              value={filtro.idSetor}
              onChange={(e) => setFiltro((f) => ({ ...f, idSetor: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              {setores.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.nome}
                </option>
              ))}
            </select>
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
                  <th>Razão Social</th>
                  <th>Nome Fantasia</th>
                  <th>Local</th>
                  <th>Telefone</th>
                  {showAcoes ? (
                    <th colSpan={2} style={{ width: '12%' }}>
                      AÇÕES
                    </th>
                  ) : null}
                </tr>
              </thead>
              <tbody>
                {items.map((empresa) => (
                  <tr key={empresa.idEmpresa}>
                    <td>{empresa.razaoSocial || '-'}</td>
                    <td>{empresa.nomeFantasia || '-'}</td>
                    <td>{empresa.local || '-'}</td>
                    <td>{maskPhone(empresa.telefone) || '-'}</td>
                    {showAcoes ? (
                      <>
                        <td>
                          {perms.showVisualizar ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Visualizar"
                              onClick={() => openCadastro(empresa, 'visualizar')}
                            >
                              <i className="fa fa-eye" aria-hidden />
                            </button>
                          ) : null}
                        </td>
                        <td>
                          {empresa.editavel ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Editar"
                              onClick={() => openCadastro(empresa, 'editar')}
                            >
                              <i className="fa fa-edit" aria-hidden />
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
