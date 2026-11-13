import { useState } from 'react'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

type RelatorioKind = 'medicao' | 'produtividade' | 'efetivo'

const META: Record<
  RelatorioKind,
  { title: string; showStatus: boolean; dualExport: boolean; voltar: string }
> = {
  medicao: {
    title: 'Relatório de Medição',
    showStatus: false,
    dualExport: true,
    voltar: '/Dashboard/Index',
  },
  produtividade: {
    title: 'Relatório de Produtividade',
    showStatus: true,
    dualExport: false,
    voltar: '/Dashboard/Index',
  },
  efetivo: {
    title: 'Relatório de Efetivo Diário',
    showStatus: false,
    dualExport: true,
    voltar: '/Dashboard/Index',
  },
}

const STATUS_OPTS = [
  { id: '', nome: 'Todos' },
  { id: '1', nome: 'Planejada' },
  { id: '2', nome: 'Em Execução' },
  { id: '3', nome: 'Pausada' },
  { id: '4', nome: 'Finalizada' },
  { id: '5', nome: 'Cancelada' },
]

function RelatorioForm({ kind }: { kind: RelatorioKind }) {
  const { shell } = useShellContext()
  const meta = META[kind]
  const [dataInicial, setDataInicial] = useState('')
  const [dataFinal, setDataFinal] = useState('')
  const [status, setStatus] = useState('')

  function gerar(tipo: 'pdf' | 'excel' | 'relatorio') {
    if (!dataInicial.trim() || !dataFinal.trim()) {
      showToast('error', 'Informe Data Inicial e Data Final.')
      return
    }
    showToast(
      'success',
      `${meta.title}: geração ${tipo.toUpperCase()} em migração (BFF M7+). Filtro ${dataInicial} → ${dataFinal}${
        status ? ` · status ${status}` : ''
      }.`,
    )
  }

  return (
    <OperadorShell variant="dashboard" shell={shell}>
      <div className="dashboard-page relatorio-page">
        <div className="panel-heading">
          <h3>{meta.title}</h3>
        </div>
        <div className="relatorio-panel">
          <div className="relatorio-grid">
            <label className="relatorio-field">
              <span>
                Data Inicial{kind !== 'produtividade' ? <em>*</em> : null}
              </span>
              <input
                type="date"
                value={dataInicial}
                onChange={(e) => setDataInicial(e.target.value)}
              />
            </label>
            <label className="relatorio-field">
              <span>
                Data Final{kind !== 'produtividade' ? <em>*</em> : null}
              </span>
              <input type="date" value={dataFinal} onChange={(e) => setDataFinal(e.target.value)} />
            </label>
            {meta.showStatus ? (
              <label className="relatorio-field">
                <span>Status</span>
                <select value={status} onChange={(e) => setStatus(e.target.value)}>
                  {STATUS_OPTS.map((o) => (
                    <option key={o.id || 'all'} value={o.id}>
                      {o.nome}
                    </option>
                  ))}
                </select>
              </label>
            ) : null}
          </div>
          <div className="relatorio-actions">
            <button type="button" className="dashboard-report-btn" onClick={() => goOperador(meta.voltar)}>
              Voltar
            </button>
            {meta.dualExport ? (
              <>
                <button type="button" className="dashboard-report-btn" onClick={() => gerar('excel')}>
                  Gerar Excel
                </button>
                <button type="button" className="dashboard-report-btn" onClick={() => gerar('pdf')}>
                  Gerar PDF
                </button>
              </>
            ) : (
              <button type="button" className="dashboard-report-btn" onClick={() => gerar('relatorio')}>
                Gerar Relatório
              </button>
            )}
          </div>
        </div>
      </div>
    </OperadorShell>
  )
}

export function RelatorioMedicaoPage() {
  return <RelatorioForm kind="medicao" />
}

export function RelatorioProdutividadePage() {
  return <RelatorioForm kind="produtividade" />
}

export function RelatorioEfetivoDiarioPage() {
  return <RelatorioForm kind="efetivo" />
}
