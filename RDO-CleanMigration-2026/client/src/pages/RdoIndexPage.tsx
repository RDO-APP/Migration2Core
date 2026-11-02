import { useCallback, useEffect, useState, type ReactNode } from 'react'
import { assinarRdo, downloadRdoPdf, fetchRdoList, fetchRdoStatusOptions } from '../api/rdoApi'
import type { RdoListItem, RdoListPage, RdoStatusOption } from '../api/equipamentos-api.types'
import { useConfirmDialog } from '../components/ConfirmDialog'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import { rdoAssinarEditarDisabled } from '../utils/rdoIndexActions'
import '../cards-page.css'
import '../rdo-index.css'

function maskDateInput(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 8)
  if (digits.length <= 2) return digits
  if (digits.length <= 4) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4)}`
}

export function RdoIndexPage() {
  const { shell } = useShellContext()
  const { ask, dialog: confirmDialog } = useConfirmDialog()
  const [statusOptions, setStatusOptions] = useState<RdoStatusOption[]>([])
  const [statusRdo, setStatusRdo] = useState(0)
  const [dataInicial, setDataInicial] = useState('')
  const [dataFinal, setDataFinal] = useState('')
  const [pageData, setPageData] = useState<RdoListPage | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [pdfBusyId, setPdfBusyId] = useState<number | null>(null)
  const [commentModalRdo, setCommentModalRdo] = useState<RdoListItem | null>(null)
  const [comentarioAssinatura, setComentarioAssinatura] = useState('')
  const [tipoComentarioAssinatura, setTipoComentarioAssinatura] = useState(0)
  const [assinando, setAssinando] = useState(false)

  const loadList = useCallback(
    async (page: number) => {
      setLoading(true)
      setError(null)
      try {
        const data = await fetchRdoList({
          page,
          statusRdo,
          dataInicial: dataInicial.trim() || undefined,
          dataFinal: dataFinal.trim() || undefined,
        })
        setPageData(data)
      } catch (e: unknown) {
        setError(e instanceof Error ? e.message : 'Falha ao carregar RDOs.')
      } finally {
        setLoading(false)
      }
    },
    [statusRdo, dataInicial, dataFinal],
  )

  useEffect(() => {
    let cancelled = false
    fetchRdoStatusOptions()
      .then((opts) => {
        if (!cancelled) setStatusOptions(opts.filter((s) => s.id !== 0))
      })
      .catch(() => {
        /* status opcional — lista ainda funciona */
      })
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    void loadList(1)
  }, [loadList])

  function onPesquisar() {
    void loadList(1)
  }

  function onPage(page: number) {
    void loadList(page)
  }

  const showNovo = shell?.showGerarRdo === true
  const showAssinarRdo = shell?.showAssinarRdo === true
  const showEditarRdo = shell?.showEditarRdo === true
  const obraFinalizada = pageData?.obraFinalizada === true
  const obraNome = shell?.obraNome ?? pageData?.obraNome
  const contratanteUsuario =
    pageData?.contratanteContratadaUsuario?.trim() || shell?.contratanteContratada?.trim() || ''

  async function onGerarPdf(rdo: RdoListItem) {
    setPdfBusyId(rdo.idRdo)
    try {
      await downloadRdoPdf(rdo.idRdo, rdo.dataRdo, true)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao gerar PDF.')
    } finally {
      setPdfBusyId(null)
    }
  }

  function onEditar(rdo: RdoListItem) {
    goOperador(`/Rdo/Cadastro?rdoId=${rdo.idRdo}`)
  }

  async function fetchClientIp(): Promise<string> {
    try {
      const res = await fetch('https://api.ipify.org?format=json')
      const j = (await res.json()) as { ip?: string }
      return j.ip ?? ''
    } catch {
      return ''
    }
  }

  async function confirmarEAssinar(
    rdo: RdoListItem,
    comentario?: string,
    tipo?: number,
  ) {
    const ok = await ask(`Tem certeza que deseja assinar o RDO de data: ${rdo.dataRdo}?`)
    if (!ok) return
    setAssinando(true)
    try {
      const ip = await fetchClientIp()
      const result = await assinarRdo(rdo.idRdo, {
        comentarioAssinatura: comentario,
        tipoComentarioAssinatura: tipo ?? 0,
        ip,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage ?? 'Não foi possível assinar o RDO.')
        return
      }
      setCommentModalRdo(null)
      showToast('success', 'Registro assinado.')
      await loadList(pageData?.currentPage ?? 1)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao assinar o RDO.')
    } finally {
      setAssinando(false)
    }
  }

  function onAssinar(rdo: RdoListItem) {
    const dono = (rdo.statusContratanteContratadaDonoRdo ?? '').trim()
    if (dono && dono !== contratanteUsuario) {
      setComentarioAssinatura('')
      setTipoComentarioAssinatura(0)
      setCommentModalRdo(rdo)
      return
    }
    void confirmarEAssinar(rdo)
  }

  const shellWrap = (body: ReactNode) => (
    <OperadorShell variant="rdo" obraNome={obraNome} shell={shell}>
      {body}
    </OperadorShell>
  )

  return shellWrap(
    <>
    <div className="rdo-index-page">
      <div className="panel-heading">
        <h3>RDO</h3>
      </div>

      <div className="panel rdo-filters-panel">
        <div className="row g-2 rdo-filters-row">
        <div className="col-md-4 col-sm-12">
          <div className="form-group is-empty">
            <label className="control-label">Status</label>
            <select
              className="form-control"
              value={statusRdo}
              onChange={(e) => setStatusRdo(Number(e.target.value))}
            >
              <option value={0}>Selecione...</option>
              {statusOptions.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.nome}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="col-md-4 col-sm-12">
          <div className="form-group">
            <label className="control-label">Data Inicial</label>
            <input
              type="text"
              className="form-control"
              placeholder="dd/mm/aaaa"
              value={dataInicial}
              onChange={(e) => setDataInicial(maskDateInput(e.target.value))}
            />
          </div>
        </div>
        <div className="col-md-4 col-sm-12">
          <div className="form-group">
            <label className="control-label">Data Final</label>
            <input
              type="text"
              className="form-control"
              placeholder="dd/mm/aaaa"
              value={dataFinal}
              onChange={(e) => setDataFinal(maskDateInput(e.target.value))}
            />
          </div>
        </div>
        <div className="col-12 rdo-filters-actions">
          <div className="rdo-filters-actions-inner">
            <button type="button" className="btn btn-blue" onClick={onPesquisar}>
              <i className="fa fa-search" aria-hidden /> PESQUISAR
            </button>
            {showNovo ? (
              <button
                type="button"
                className="btn btn-blue"
                disabled={obraFinalizada}
                onClick={() => goOperador(P3_NAV.toolbar.gerarRdo)}
              >
                <i className="fa fa-plus" aria-hidden /> NOVO
              </button>
            ) : null}
          </div>
        </div>
        </div>
      </div>

      {error ? <div className="rdo-error">{error}</div> : null}

      <div className="lista-tarefas">
        <div className="tabela">
          <div className="table-responsive">
          <table className="table table-striped">
            <thead>
              <tr>
                <th>Data do RDO</th>
                <th>Dia da Semana</th>
                <th>Status</th>
                <th>Qtd Tarefas</th>
                <th>Qtd Colaboradores</th>
                <th>Qtd Equipamentos</th>
                <th colSpan={3}>AÇÕES</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={9} className="rdo-empty">
                    Carregando…
                  </td>
                </tr>
              ) : pageData && pageData.items.length === 0 ? (
                <tr>
                  <td colSpan={9} className="rdo-empty">
                    Nenhum registro encontrado.
                  </td>
                </tr>
              ) : (
                pageData?.items.map((rdo: RdoListItem) => {
                  const acoesDisabled = rdoAssinarEditarDisabled(rdo.statusRdo, contratanteUsuario)
                  return (
                  <tr key={rdo.idRdo}>
                    <td>{rdo.dataRdo}</td>
                    <td>{rdo.diaDaSemana}</td>
                    <td>{rdo.descricaoStatus}</td>
                    <td>{rdo.qtdTarefas}</td>
                    <td>{rdo.qtdColaboradores}</td>
                    <td>{rdo.qtdMaquinas}</td>
                    <td className="rdo-acoes" colSpan={3}>
                      <div className="rdo-acoes-inner">
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title="Imprimir"
                          aria-label={`Imprimir RDO ${rdo.dataRdo}`}
                          disabled={pdfBusyId !== null}
                          onClick={(e) => {
                            e.preventDefault()
                            e.stopPropagation()
                            void onGerarPdf(rdo)
                          }}
                        >
                          <i className="fa fa-file-pdf-o" aria-hidden />
                        </button>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title={showAssinarRdo === false ? 'Assinar (sem permissão)' : 'Assinar'}
                          aria-label={`Assinar RDO ${rdo.dataRdo}`}
                          disabled={acoesDisabled || showAssinarRdo === false || assinando}
                          onClick={(e) => {
                            e.preventDefault()
                            e.stopPropagation()
                            onAssinar(rdo)
                          }}
                        >
                          <i className="icon-assinar" aria-hidden />
                        </button>
                        <button
                          type="button"
                          className="btn btn-simple btn-just-icon"
                          title={showEditarRdo === false ? 'Editar (sem permissão)' : 'Editar'}
                          aria-label={`Editar RDO ${rdo.dataRdo}`}
                          disabled={acoesDisabled || showEditarRdo === false}
                          onClick={(e) => {
                            e.preventDefault()
                            e.stopPropagation()
                            onEditar(rdo)
                          }}
                        >
                          <i className="fa fa-edit" aria-hidden />
                        </button>
                      </div>
                    </td>
                  </tr>
                  )
                })
              )}
            </tbody>
          </table>
          </div>

          {pageData && pageData.totalPages > 1 ? (
            <ul className="pagination rdo-pagination">
              {Array.from({ length: pageData.totalPages }, (_, i) => i + 1).map((p) => (
                <li key={p} className={p === pageData.currentPage ? 'active' : undefined}>
                  <a
                    href="#"
                    role="button"
                    onClick={(e) => {
                      e.preventDefault()
                      onPage(p)
                    }}
                  >
                    {p}
                  </a>
                </li>
              ))}
            </ul>
          ) : null}
        </div>
      </div>
    </div>
    {confirmDialog}
    {commentModalRdo ? (
      <div className="rdo-modal-backdrop" role="presentation">
        <div
          className="rdo-modal"
          role="dialog"
          aria-labelledby="rdo-assinar-titulo"
        >
          <div className="rdo-modal-header">
            <h4 id="rdo-assinar-titulo">COMENTÁRIOS</h4>
            <button
              type="button"
              className="btn btn-simple"
              onClick={() => setCommentModalRdo(null)}
            >
              Fechar
            </button>
          </div>
          <div className="rdo-modal-body">
            <textarea
              className="form-control"
              rows={6}
              maxLength={2000}
              value={comentarioAssinatura}
              onChange={(e) => setComentarioAssinatura(e.target.value)}
            />
            <div className="rdo-assinar-thumbs">
              <button
                type="button"
                className="btn btn-transparent"
                title="Positivo"
                onClick={() => setTipoComentarioAssinatura(1)}
              >
                <i
                  className={
                    tipoComentarioAssinatura === 1 ? 'fa fa-thumbs-up' : 'fa fa-thumbs-o-up'
                  }
                  aria-hidden
                />
              </button>
              <button
                type="button"
                className="btn btn-transparent"
                title="Negativo"
                onClick={() => setTipoComentarioAssinatura(2)}
              >
                <i
                  className={
                    tipoComentarioAssinatura === 2 ? 'fa fa-thumbs-down' : 'fa fa-thumbs-o-down'
                  }
                  aria-hidden
                />
              </button>
            </div>
          </div>
          <div className="rdo-modal-footer">
            <button
              type="button"
              className="btn btn-simple"
              onClick={() => setCommentModalRdo(null)}
            >
              Cancelar
            </button>
            <button
              type="button"
              className="btn btn-default btn-simple"
              disabled={assinando}
              onClick={() => {
                if (!commentModalRdo) return
                void confirmarEAssinar(
                  commentModalRdo,
                  comentarioAssinatura,
                  tipoComentarioAssinatura,
                )
              }}
            >
              Adicionar
            </button>
          </div>
        </div>
      </div>
    ) : null}
    </>,
  )
}
