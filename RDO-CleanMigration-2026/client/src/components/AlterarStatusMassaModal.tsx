import { useState } from 'react'
import { atualizarStatusTarefasEmMassa } from '../api/tarefaApi'
import { showToast } from '../toast'

const STATUS_OPCOES = [
  { id: 1, nome: 'Planejada' },
  { id: 2, nome: 'Em Execução' },
  { id: 3, nome: 'Finalizada' },
  { id: 4, nome: 'Pausada' },
  { id: 5, nome: 'Cancelada' },
]

type Props = {
  tarefaIds: number[]
  onClose: () => void
  onSaved: () => void
}

export function AlterarStatusMassaModal({ tarefaIds, onClose, onSaved }: Props) {
  const [idStatus, setIdStatus] = useState(0)
  const [saving, setSaving] = useState(false)

  async function onSalvar() {
    if (idStatus <= 0) {
      showToast('error', 'Selecione o status.')
      return
    }
    setSaving(true)
    try {
      const result = await atualizarStatusTarefasEmMassa(tarefaIds, idStatus)
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Falha ao alterar status.')
        return
      }
      const msg =
        result.failed && result.failed > 0
          ? `Status alterado em ${result.updated}. ${result.failed} sem permissão de transição.`
          : 'Status alterados com sucesso.'
      showToast('success', msg)
      onSaved()
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao alterar status.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="tarefa-modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="tarefa-modal"
        role="dialog"
        aria-labelledby="status-massa-titulo"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="tarefa-modal-header">
          <h4 id="status-massa-titulo">Alterar Status em Massa ({tarefaIds.length})</h4>
          <button type="button" className="btn btn-simple" onClick={onClose} aria-label="Fechar">
            ×
          </button>
        </div>
        <div className="tarefa-modal-body">
          <div className="form-group">
            <label className="control-label">Status</label>
            <select
              className="form-control"
              value={idStatus || ''}
              onChange={(e) => setIdStatus(Number(e.target.value) || 0)}
            >
              <option value="">Selecione...</option>
              {STATUS_OPCOES.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.nome}
                </option>
              ))}
            </select>
          </div>
        </div>
        <div className="tarefa-modal-footer">
          <button type="button" className="btn btn-simple" onClick={onClose} disabled={saving}>
            Cancelar
          </button>
          <button type="button" className="btn btn-blue" onClick={() => void onSalvar()} disabled={saving}>
            Salvar
          </button>
        </div>
      </div>
    </div>
  )
}
