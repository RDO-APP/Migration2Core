import { useEffect, useState } from 'react'
import { fetchTarefaCadastro } from '../api/tarefaApi'
import type { TarefaCadastroHistorico } from '../api/equipamentos-api.types'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'

type HistoricoMedicaoModalProps = {
  tarefaId: number
  descricaoTarefa?: string
  onClose: () => void
}

function dash(v?: string): string {
  const t = v?.trim()
  return t ? t : '—'
}

function hora5(v?: string): string {
  const t = v?.trim()
  if (!t) return '—'
  return t.length > 5 ? t.slice(0, 5) : t
}

function fmtNum(v?: number | null): string {
  if (v == null) return '—'
  return String(v)
}

export function HistoricoMedicaoModal({ tarefaId, descricaoTarefa, onClose }: HistoricoMedicaoModalProps) {
  const [descricao, setDescricao] = useState(descricaoTarefa ?? '')
  const [rows, setRows] = useState<TarefaCadastroHistorico[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    fetchTarefaCadastro(tarefaId)
      .then((dto) => {
        if (cancelled) return
        setDescricao(dto.descricao || descricaoTarefa || '')
        setRows(dto.listaHistoricoTarefa ?? [])
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          showToast('error', e instanceof Error ? e.message : 'Falha ao carregar histórico.')
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [tarefaId, descricaoTarefa])

  return (
    <div className="tarefa-modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="tarefa-modal tarefa-modal-wide"
        role="dialog"
        aria-labelledby="historico-medicoes-titulo"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="tarefa-modal-header">
          <h4 id="historico-medicoes-titulo">Medição</h4>
          <button type="button" className="btn btn-simple" onClick={onClose} aria-label="Fechar">
            ×
          </button>
        </div>
        <div className="tarefa-modal-body">
          <h4>{descricao}</h4>
          {loading ? (
            <p className="muted">Carregando…</p>
          ) : (
            <div className="tabela table-responsive">
              <table className="table table-striped">
                <thead>
                  <tr>
                    <th>Data</th>
                    <th>Hora Inicial</th>
                    <th>Hora Final</th>
                    <th>Status</th>
                    <th>Horímetro Inicial</th>
                    <th>Horímetro Final</th>
                    <th>Horas Trabalhadas</th>
                    <th>Qtde Construída</th>
                    <th>Unidade</th>
                    <th>Usuário</th>
                    <th colSpan={2} />
                  </tr>
                </thead>
                <tbody>
                  {rows.length === 0 ? (
                    <tr>
                      <td colSpan={12}>Nenhum registro encontrado.</td>
                    </tr>
                  ) : (
                    rows.map((h) => (
                      <tr key={h.idTarefa}>
                        <td>{dash(h.data)}</td>
                        <td>{hora5(h.horaInicial)}</td>
                        <td>{hora5(h.horaFinal)}</td>
                        <td>{dash(h.descricaoStatusTarefa)}</td>
                        <td>{fmtNum(h.horimetroInicial)}</td>
                        <td>{fmtNum(h.horimetroFinal)}</td>
                        <td>{fmtNum(h.horimetroTotal)}</td>
                        <td>{fmtNum(h.qtdConstruida)}</td>
                        <td>{dash(h.unidadeMedida)}</td>
                        <td>{dash(h.nomeColaborador)}</td>
                        <td>
                          <button
                            type="button"
                            className="btn btn-simple btn-just-icon"
                            title="Visualizar Tarefa"
                            onClick={() => goOperador(`/Tarefa/Cadastro?id=${h.idTarefa}&modo=visualizar`)}
                          >
                            <i className="fa fa-eye" aria-hidden="true" />
                          </button>
                        </td>
                        <td>
                          {!h.rdoAssinado ? (
                            <button
                              type="button"
                              className="btn btn-simple btn-just-icon"
                              title="Editar Tarefa"
                              onClick={() => goOperador(`/Tarefa/Cadastro?id=${h.idTarefa}`)}
                            >
                              <i className="fa fa-edit" aria-hidden="true" />
                            </button>
                          ) : null}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
        <div className="tarefa-modal-footer">
          <button type="button" className="btn btn-simple" onClick={onClose}>
            × Cancelar
          </button>
        </div>
      </div>
    </div>
  )
}
