import { useCallback, useEffect, useState } from 'react'
import {
  deleteObraIndex,
  enviarConviteObra,
  fetchObraIndexBootstrap,
  fetchObraIndexLista,
  fetchObraIndexMunicipios,
  selecionarObra,
  type ObraIndexFilter,
  type ObraIndexItem,
  type ObraIndexLookup,
  type ObraIndexPermissions,
} from '../api/obrasApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

const EMPTY_FILTRO: ObraIndexFilter = {
  descricao: '',
  idContratante: 0,
  dataInicioDe: '',
  dataInicioAte: '',
  idUf: 0,
  idMunicipio: 0,
  statusObra: 0,
}

const EMPTY_PERMS: ObraIndexPermissions = {
  showVisualizar: false,
  showEnviarConvite: false,
  showCopiar: false,
  showEditar: false,
  showDeletar: false,
  showCriarNovo: false,
}

export function ObraIndexPage() {
  const { shell } = useShellContext()
  const [obraNome, setObraNome] = useState<string | undefined>()
  const [filtro, setFiltro] = useState<ObraIndexFilter>(EMPTY_FILTRO)
  const [empresas, setEmpresas] = useState<ObraIndexLookup[]>([])
  const [ufs, setUfs] = useState<ObraIndexLookup[]>([])
  const [municipios, setMunicipios] = useState<ObraIndexLookup[]>([])
  const [perms, setPerms] = useState<ObraIndexPermissions>(EMPTY_PERMS)
  const [items, setItems] = useState<ObraIndexItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<number | null>(null)
  const [conviteObra, setConviteObra] = useState<ObraIndexItem | null>(null)
  const [conviteEmail, setConviteEmail] = useState('')
  const [enviandoConvite, setEnviandoConvite] = useState(false)

  const carregar = useCallback(async (f: ObraIndexFilter) => {
    setSearching(true)
    setError(null)
    try {
      const data = await fetchObraIndexLista(f)
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
    let cancelled = false
    void (async () => {
      try {
        const boot = await fetchObraIndexBootstrap()
        if (cancelled) return
        setEmpresas(boot.empresas)
        setUfs(boot.ufs)
        setPerms(boot.permissions)
        setObraNome(boot.obraNomeSessao || undefined)
        await carregar(EMPTY_FILTRO)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar obras.'
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
      setMunicipios(await fetchObraIndexMunicipios(idUf))
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao carregar municípios.')
      setMunicipios([])
    }
  }

  async function openCadastro(item: ObraIndexItem, modo: 'editar' | 'visualizar') {
    setBusyId(item.idObra)
    try {
      await selecionarObra(item.idObra)
      const q = modo === 'visualizar' ? '?modo=visualizar' : ''
      goOperador(`${P3_NAV.toolbar.editarObra}${q}`)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível abrir a obra.')
    } finally {
      setBusyId(null)
    }
  }

  function onCopiar(item: ObraIndexItem) {
    showToast(
      'error',
      `Cópia de «${item.descricao}» ainda em migração (criar obra nova com os dados). Use NOVO quando disponível.`,
    )
  }

  async function onExcluir(item: ObraIndexItem) {
    if (!window.confirm(`Tem certeza que deseja excluir o registro: ${item.descricao}?`)) {
      return
    }
    setBusyId(item.idObra)
    try {
      const result = await deleteObraIndex(item.idObra)
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

  async function onEnviarConvite() {
    if (!conviteObra) return
    setEnviandoConvite(true)
    try {
      const result = await enviarConviteObra(conviteObra.idObra, conviteEmail)
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível enviar o convite.')
        return
      }
      showToast('success', 'Convite enviado com sucesso.')
      setConviteObra(null)
      setConviteEmail('')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível enviar o convite.')
    } finally {
      setEnviandoConvite(false)
    }
  }

  const showAcoes =
    perms.showVisualizar ||
    perms.showEnviarConvite ||
    perms.showCopiar ||
    perms.showEditar ||
    perms.showDeletar

  return (
    <OperadorShell variant="cards" obraNome={obraNome ?? shell?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Obras</h3>
        </div>

        <div className="panel efetivo-filtros" style={{ gridTemplateColumns: 'repeat(2, minmax(0, 1fr))' }}>
          <div className="form-group">
            <label className="control-label">Nome</label>
            <input
              type="text"
              className="form-control"
              maxLength={100}
              value={filtro.descricao}
              onChange={(e) => setFiltro((f) => ({ ...f, descricao: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Contratante</label>
            <select
              className="form-control"
              value={filtro.idContratante}
              onChange={(e) => setFiltro((f) => ({ ...f, idContratante: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              {empresas.map((e) => (
                <option key={e.id} value={e.id}>
                  {e.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Data Inicial</label>
            <input
              type="text"
              className="form-control"
              placeholder="dd/mm/aaaa"
              maxLength={10}
              value={filtro.dataInicioDe}
              onChange={(e) => setFiltro((f) => ({ ...f, dataInicioDe: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Data Final</label>
            <input
              type="text"
              className="form-control"
              placeholder="dd/mm/aaaa"
              maxLength={10}
              value={filtro.dataInicioAte}
              onChange={(e) => setFiltro((f) => ({ ...f, dataInicioAte: e.target.value }))}
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
            <label className="control-label">Status</label>
            <select
              className="form-control"
              value={filtro.statusObra}
              onChange={(e) => setFiltro((f) => ({ ...f, statusObra: Number(e.target.value) || 0 }))}
            >
              <option value={0}>Selecione...</option>
              <option value={1}>Em execução</option>
              <option value={2}>Finalizadas</option>
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
            {perms.showCriarNovo ? (
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
                  {showAcoes ? (
                    <th colSpan={5} style={{ width: '18%' }}>
                      AÇÕES
                    </th>
                  ) : null}
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
                    {perms.showVisualizar ? (
                      <td>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title="Visualizar"
                          disabled={busyId === obra.idObra}
                          onClick={() => void openCadastro(obra, 'visualizar')}
                        >
                          <i className="fa fa-eye" aria-hidden />
                        </button>
                      </td>
                    ) : null}
                    {perms.showEnviarConvite ? (
                      <td>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title="Enviar Convite"
                          onClick={() => {
                            setConviteObra(obra)
                            setConviteEmail('')
                          }}
                        >
                          <i className="fa fa-send" aria-hidden />
                        </button>
                      </td>
                    ) : null}
                    {perms.showCopiar ? (
                      <td>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title="Copiar Obra"
                          onClick={() => onCopiar(obra)}
                        >
                          <i className="fa fa-copy" aria-hidden />
                        </button>
                      </td>
                    ) : null}
                    {perms.showEditar ? (
                      <td>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title="Editar"
                          disabled={busyId === obra.idObra}
                          onClick={() => void openCadastro(obra, 'editar')}
                        >
                          <i className="fa fa-edit" aria-hidden />
                        </button>
                      </td>
                    ) : null}
                    {perms.showDeletar ? (
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
                    ) : null}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}

        {conviteObra ? (
          <div
            role="dialog"
            aria-modal
            aria-label="Convidar empresa"
            style={{
              position: 'fixed',
              inset: 0,
              zIndex: 4000,
              background: 'rgb(0 0 0 / 45%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: 16,
            }}
            onClick={() => setConviteObra(null)}
          >
            <div
              className="panel"
              style={{ maxWidth: 520, width: '100%', background: '#fff', padding: 16 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="panel-heading">
                <h4>CONVIDAR EMPRESA</h4>
              </div>
              <p className="muted" style={{ marginBottom: 12 }}>
                Obra: <strong>{conviteObra.descricao}</strong>
              </p>
              <div className="form-group">
                <label className="control-label">E-mail</label>
                <input
                  type="email"
                  className="form-control"
                  maxLength={50}
                  value={conviteEmail}
                  onChange={(e) => setConviteEmail(e.target.value)}
                />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="btn btn-simple" onClick={() => setConviteObra(null)}>
                  Cancelar
                </button>
                <button
                  type="button"
                  className="btn btn-blue"
                  disabled={enviandoConvite}
                  onClick={() => void onEnviarConvite()}
                >
                  Enviar Convite
                </button>
              </div>
            </div>
          </div>
        ) : null}
      </section>
    </OperadorShell>
  )
}
