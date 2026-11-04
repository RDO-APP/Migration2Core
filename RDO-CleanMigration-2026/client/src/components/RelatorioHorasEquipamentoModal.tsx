import { useState } from 'react'
import { downloadRelatorioHorasEquipamento } from '../api/tarefaApi'
import { showToast } from '../toast'
import { maskDateInput } from '../tarefaCadastroShared'

type RelatorioHorasEquipamentoModalProps = {
  tarefaId: number
  descricaoTarefa: string
  onClose: () => void
}

function parseBrDate(value: string): Date | null {
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(value.trim())
  if (!m) return null
  const d = new Date(Number(m[3]), Number(m[2]) - 1, Number(m[1]))
  if (d.getFullYear() !== Number(m[3]) || d.getMonth() !== Number(m[2]) - 1 || d.getDate() !== Number(m[1])) {
    return null
  }
  return d
}

export function RelatorioHorasEquipamentoModal({
  tarefaId,
  descricaoTarefa,
  onClose,
}: RelatorioHorasEquipamentoModalProps) {
  const [dataInicial, setDataInicial] = useState('')
  const [dataFinal, setDataFinal] = useState('')
  const [busy, setBusy] = useState(false)

  function validar(): boolean {
    if (!dataInicial.trim()) {
      showToast('error', 'A Data Inicial deve ser preenchida.')
      return false
    }
    if (!parseBrDate(dataInicial)) {
      showToast('error', 'A Data Inicial é inválida.')
      return false
    }
    if (!dataFinal.trim()) {
      showToast('error', 'A Data Final deve ser preenchida.')
      return false
    }
    if (!parseBrDate(dataFinal)) {
      showToast('error', 'A Data Final é inválida.')
      return false
    }
    const a = parseBrDate(dataInicial)!
    const b = parseBrDate(dataFinal)!
    if (a > b) {
      showToast('error', 'A Data Final não pode ser menor que a Data Inicial.')
      return false
    }
    return true
  }

  async function gerar(tipoRelatorio: 'PDF' | 'Excel') {
    if (!validar()) return
    setBusy(true)
    try {
      await downloadRelatorioHorasEquipamento(tarefaId, {
        dataInicial,
        dataFinal,
        tipoRelatorio,
        descricaoTarefa,
      })
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível gerar o relatório.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="tarefa-modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="tarefa-modal"
        role="dialog"
        aria-labelledby="relatorio-horas-titulo"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="tarefa-modal-header">
          <h4 id="relatorio-horas-titulo">Relatório Controle de Horas - {descricaoTarefa}</h4>
          <button type="button" className="btn btn-simple" onClick={onClose} aria-label="Fechar">
            ×
          </button>
        </div>
        <div className="tarefa-modal-body">
          <div className="row">
            <div className="col-md-6 col-sm-12">
              <div className="form-group">
                <label className="control-label">
                  Data<span style={{ color: 'red' }}>*</span>
                </label>
                <input
                  className="form-control"
                  value={dataInicial}
                  placeholder="__/__/____"
                  onChange={(e) => setDataInicial(maskDateInput(e.target.value))}
                />
              </div>
            </div>
            <div className="col-md-6 col-sm-12">
              <div className="form-group">
                <label className="control-label">
                  Data<span style={{ color: 'red' }}>*</span>
                </label>
                <input
                  className="form-control"
                  value={dataFinal}
                  placeholder="__/__/____"
                  onChange={(e) => setDataFinal(maskDateInput(e.target.value))}
                />
              </div>
            </div>
          </div>
        </div>
        <div className="tarefa-modal-footer">
          <button type="button" className="btn btn-blue" disabled={busy} onClick={() => void gerar('Excel')}>
            <i className="fa fa-plus" aria-hidden="true" /> GERAR EXCEL
          </button>
          <button type="button" className="btn btn-blue" disabled={busy} onClick={() => void gerar('PDF')}>
            <i className="fa fa-plus" aria-hidden="true" /> GERAR PDF
          </button>
          <button type="button" className="btn btn-simple" onClick={onClose}>
            × Cancelar
          </button>
        </div>
      </div>
    </div>
  )
}
