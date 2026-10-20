import type { ObraListItem } from '../api/equipamentos-api.types'

type WorkCardObraProps = {
  obra: ObraListItem
  disabled?: boolean
  onSelect: (idObra: number) => void
}

export function WorkCardObra({ obra, disabled, onSelect }: WorkCardObraProps) {
  const pct = Math.min(100, Math.max(0, obra.progressoPorcentagem ?? 0))
  const iconRole = obra.contratanteContratada?.trim() || 'contratada'
  const cssBar = obra.classeStatusCss?.trim() || 'bg-cinza'
  const licenca = obra.statusBasicaGratuita?.trim()
  const restante = Math.max(0, 100 - pct)

  return (
    <div className="item col-md-6 col-lg-4">
      <button
        type="button"
        className="btn change-background"
        disabled={disabled}
        onClick={() => onSelect(obra.idObra)}
      >
        <i className={`icon-${iconRole}`} aria-hidden />
        <h5>{obra.descricao}</h5>
        {obra.cidadeEstado ? <p>{obra.cidadeEstado}</p> : null}
        {licenca ? <p>({licenca.toUpperCase()})</p> : null}
        <small>STATUS</small>
        <div className={`progress progress-line-info ${cssBar}`}>
          <div
            className="progress-bar progress-bar-info"
            role="progressbar"
            aria-valuenow={pct}
            aria-valuemin={0}
            aria-valuemax={100}
            style={{ width: `${restante}%` }}
          >
            <span className="branco">{pct}%</span>
          </div>
          <span className="azul">{pct}%</span>
        </div>
      </button>
    </div>
  )
}
