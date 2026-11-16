import { useCallback, useEffect, useState, type CSSProperties } from 'react'
import {
  copiarEfetivo,
  fetchEfetivoBootstrap,
  fetchEfetivoList,
  updateEfetivoStatus,
  type EfetivoBootstrap,
  type EfetivoItem,
  type EfetivoLookup,
} from '../api/efetivoApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../efetivo-page.css'

type Filtro = {
  data: string
  nome: string
  cargoId: number
  statusId: number
}

export function EfetivoIndexPage() {
  const { shell } = useShellContext()
  const [boot, setBoot] = useState<EfetivoBootstrap | null>(null)
  const [filtro, setFiltro] = useState<Filtro>({ data: '', nome: '', cargoId: 0, statusId: 0 })
  const [items, setItems] = useState<EfetivoItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searching, setSearching] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [savingId, setSavingId] = useState<number | null>(null)
  const [modalCopiar, setModalCopiar] = useState(false)
  const [dataCopia, setDataCopia] = useState('')
  const [copiando, setCopiando] = useState(false)

  const carregarLista = useCallback(async (f: Filtro) => {
    if (!f.data.trim()) {
      showToast('error', 'Informe a data.')
      return
    }
    setSearching(true)
    setError(null)
    try {
      const list = await fetchEfetivoList({
        data: f.data,
        nome: f.nome,
        cargoId: f.cargoId,
        statusId: f.statusId,
      })
      setItems(list.items)
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar efetivo.'
      setError(msg)
      showToast('error', msg)
    } finally {
      setSearching(false)
    }
  }, [])

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        const b = await fetchEfetivoBootstrap()
        if (cancelled) return
        setBoot(b)
        const f: Filtro = { data: b.dataPadrao, nome: '', cargoId: 0, statusId: 0 }
        setFiltro(f)
        setLoading(false)
        await carregarLista(f)
      } catch (e: unknown) {
        if (cancelled) return
        const msg = e instanceof Error ? e.message : 'Falha ao carregar efetivo.'
        setError(msg)
        showToast('error', msg)
        setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [carregarLista])

  async function onChangeStatus(item: EfetivoItem, idStatus: number) {
    setSavingId(item.idObraColaborador)
    try {
      const result = await updateEfetivoStatus({
        idEfetivo: item.idEfetivo,
        idObraColaborador: item.idObraColaborador,
        idStatus,
        data: filtro.data,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Falha ao alterar situação.')
        return
      }
      const statusMeta = boot?.statuses.find((s) => s.id === idStatus)
      setItems((prev) =>
        prev.map((row) =>
          row.idObraColaborador === item.idObraColaborador
            ? {
                ...row,
                idEfetivo: result.idEfetivo ?? row.idEfetivo,
                idStatus,
                nomeStatus: statusMeta?.nome ?? '',
                cor: statusMeta?.cor ?? null,
              }
            : row,
        ),
      )
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao alterar situação.')
    } finally {
      setSavingId(null)
    }
  }

  async function onCopiar() {
    if (!dataCopia.trim()) {
      showToast('error', 'Por favor, selecione uma data que deseja copiar o efetivo.')
      return
    }
    setCopiando(true)
    try {
      const result = await copiarEfetivo({
        dataOrigem: filtro.data,
        dataDestino: dataCopia.trim(),
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Falha ao copiar efetivo.')
        return
      }
      showToast('success', 'Efetivo copiado com sucesso')
      setModalCopiar(false)
      const next: Filtro = { ...filtro, data: dataCopia.trim() }
      setFiltro(next)
      setDataCopia('')
      await carregarLista(next)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao copiar efetivo.')
    } finally {
      setCopiando(false)
    }
  }

  /** Prod abre modal #novo-colaborador; homolog: cadastro SPA (mesmo BFF) e volta ao efetivo. */
  function onAdicionarColaborador() {
    goOperador('/Colaborador/Cadastro')
  }

  const statuses: EfetivoLookup[] = boot?.statuses ?? []

  return (
    <OperadorShell variant="cards" obraNome={boot?.obraNome} shell={shell}>
      <section className="efetivo-page cards-page">
        <div className="panel-heading">
          <h3>Efetivo Diário</h3>
          <div className="action">
            <button
              type="button"
              className="btn btn-simple"
              title="Copiar Efetivo"
              onClick={() => {
                setDataCopia('')
                setModalCopiar(true)
              }}
            >
              <i className="fa fa-copy" aria-hidden />
            </button>
            <button
              type="button"
              className="btn btn-simple"
              title="Adicionar Colaborador"
              onClick={onAdicionarColaborador}
            >
              <i className="icon-obras" aria-hidden />
            </button>
          </div>
        </div>

        <div className="panel efetivo-filtros">
          <div className="form-group">
            <label className="control-label">
              Data<span style={{ color: 'red' }}>*</span>
            </label>
            <input
              type="text"
              className="form-control"
              placeholder="dd/mm/aaaa"
              maxLength={10}
              value={filtro.data}
              onChange={(e) => setFiltro((f) => ({ ...f, data: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Nome colaborador</label>
            <input
              type="text"
              className="form-control"
              maxLength={50}
              value={filtro.nome}
              onChange={(e) => setFiltro((f) => ({ ...f, nome: e.target.value }))}
            />
          </div>
          <div className="form-group">
            <label className="control-label">Cargo</label>
            <select
              className="form-control"
              value={filtro.cargoId}
              onChange={(e) => setFiltro((f) => ({ ...f, cargoId: Number(e.target.value) }))}
            >
              <option value={0}>Todos</option>
              {(boot?.cargos ?? []).map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="control-label">Situação</label>
            <select
              className="form-control"
              value={filtro.statusId}
              onChange={(e) => setFiltro((f) => ({ ...f, statusId: Number(e.target.value) }))}
            >
              <option value={0}>Todas</option>
              {statuses.map((s) => (
                <option key={s.id} value={s.id} style={s.cor ? { color: s.cor } : undefined}>
                  {s.nome}
                </option>
              ))}
            </select>
          </div>
          <div className="efetivo-filtros-actions">
            <button
              type="button"
              className="btn btn-blue"
              disabled={searching || loading}
              onClick={() => void carregarLista(filtro)}
            >
              <i className="fa fa-search" aria-hidden />
              PESQUISAR
            </button>
          </div>
        </div>

        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <p className="error">{error}</p> : null}

        {!loading && !error ? (
          <div className="lista-tarefas">
            {items.length === 0 ? (
              <label className="efetivo-empty">Nenhum registro encontrado.</label>
            ) : (
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>Data</th>
                      <th>Nome</th>
                      <th>Cargo</th>
                      <th style={{ width: '15%' }}>Situação</th>
                    </tr>
                  </thead>
                  <tbody>
                    {items.map((row) => {
                      const colorStyle: CSSProperties | undefined = row.cor
                        ? { color: row.cor }
                        : undefined
                      return (
                        <tr key={row.idObraColaborador}>
                          <td style={colorStyle}>{row.data}</td>
                          <td style={colorStyle}>{row.nomeColaborador}</td>
                          <td style={colorStyle}>{row.cargo}</td>
                          <td>
                            <select
                              className="form-control"
                              style={colorStyle}
                              disabled={savingId === row.idObraColaborador}
                              value={row.idStatus}
                              onChange={(e) => void onChangeStatus(row, Number(e.target.value))}
                            >
                              <option value={0}>Selecione...</option>
                              {statuses.map((s) => (
                                <option
                                  key={s.id}
                                  value={s.id}
                                  style={s.cor ? { color: s.cor } : undefined}
                                >
                                  {s.nome}
                                </option>
                              ))}
                            </select>
                          </td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        ) : null}
      </section>

      {modalCopiar ? (
        <div
          className="efetivo-modal-backdrop"
          role="presentation"
          onClick={() => !copiando && setModalCopiar(false)}
        >
          <div
            className="efetivo-modal"
            role="dialog"
            aria-labelledby="copiar-efetivo-title"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="efetivo-modal-header">
              <h4 id="copiar-efetivo-title">COPIAR EFETIVO</h4>
              <button
                type="button"
                className="btn btn-simple"
                aria-label="Fechar"
                disabled={copiando}
                onClick={() => setModalCopiar(false)}
              >
                ×
              </button>
            </div>
            <div className="efetivo-modal-body">
              <p className="muted" style={{ marginTop: 0 }}>
                Origem: <strong>{filtro.data || '—'}</strong>
              </p>
              <div className="form-group">
                <label className="control-label">
                  Selecione uma data para copiar<span style={{ color: 'red' }}>*</span>
                </label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="dd/mm/aaaa"
                  maxLength={10}
                  value={dataCopia}
                  onChange={(e) => setDataCopia(e.target.value)}
                  autoFocus
                />
              </div>
            </div>
            <div className="efetivo-modal-footer">
              <button
                type="button"
                className="btn btn-secondary"
                disabled={copiando}
                onClick={() => setModalCopiar(false)}
              >
                Cancelar
              </button>
              <button
                type="button"
                className="btn btn-blue"
                disabled={copiando}
                onClick={() => void onCopiar()}
              >
                {copiando ? 'Copiando…' : 'Copiar'}
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </OperadorShell>
  )
}
