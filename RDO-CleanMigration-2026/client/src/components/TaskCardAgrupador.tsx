import type { TarefaCard } from '../api/equipamentos-api.types'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'

type TaskCardAgrupadorProps = {
  tarefa: TarefaCard
  etapaId?: number
}

function formatPair(inicio?: string, fim?: string): string {
  const a = inicio?.trim() || '—'
  const b = fim?.trim() || '—'
  return `${a} À ${b}`
}

/** M4.7 layout · M4.7b navegação → rotas MVC (EmMigracao até M7). */
export function TaskCardAgrupador({ tarefa, etapaId }: TaskCardAgrupadorProps) {
  const pct = Math.min(100, Math.max(0, tarefa.percentualConcluido ?? 0))
  const headClass = tarefa.classeStatusCss?.trim() || 'bg-cinza'
  const percentualExtrapolado = tarefa.percentualExtrapolado === 'false'
  const restante = Math.max(0, 100 - pct)
  const colab = tarefa.quantidadeColaboradores ?? 0
  const equip = tarefa.quantidadeEquipamentos ?? 0
  const nav = P3_NAV.card(tarefa.id, etapaId)

  return (
    <div className="item">
      <div className="card">
        <div className={`head ${headClass}`}>
          <i className="icon-" aria-hidden="true" />
          <h5>{tarefa.descricao}</h5>
          <button
            type="button"
            className="fa fa-ellipsis-v btn btn-simple bt-status"
            title="Alterar Status"
            onClick={() => goOperador(nav.alterarStatus)}
          />
          <div className="icones">
            <div className="inf no-padding-right">
              <i className="fa fa-male" aria-hidden="true" title="Colaboradores" />
              <span title="Colaboradores">{colab}</span>
              <i className="icon-trator" aria-hidden="true" title="Equipamentos" />
              <span title="Equipamentos">{equip}</span>
            </div>
            <div className="actions no-padding">
              <div className="pull-right">
                <button
                  type="button"
                  className="btn btn-simple"
                  title="Visualizar Tarefa"
                  onClick={() => goOperador(nav.visualizar)}
                >
                  <i className="fa fa-eye" aria-hidden="true" />
                </button>
                <button
                  type="button"
                  className="btn btn-simple"
                  title="Histórico de Medições"
                  onClick={() => goOperador(nav.historicoMedicao)}
                >
                  <i className="fa fa-clock-o" aria-hidden="true" />
                </button>
                <button
                  type="button"
                  className="btn btn-simple"
                  title="Editar Tarefa"
                  onClick={() => goOperador(nav.editar)}
                >
                  <i className="fa fa-pencil" aria-hidden="true" />
                </button>
                <button
                  type="button"
                  className="btn btn-simple"
                  title="Relatório de Controle de Horas por Equipamento"
                  onClick={() => goOperador(nav.relatorioHorasEquipamento)}
                >
                  <i className="fa fa-print" aria-hidden="true" />
                </button>
                <button
                  type="button"
                  className="btn btn-simple"
                  title="Nova Medição"
                  onClick={() => goOperador(nav.novaMedicao)}
                >
                  <i className="fa fa-plus" aria-hidden="true" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <div className="datas">
          <div className="no-padding">
            <label className="icon-planejada">{formatPair(tarefa.dataInicio, tarefa.dataPrevisaoFim)}</label>
          </div>
          {tarefa.existeExecucao ? (
            <div className="no-padding">
              <label className="icon-executada">
                {formatPair(tarefa.primeiraExecucao, tarefa.ultimaExecucao)}
              </label>
            </div>
          ) : null}
        </div>

        <div className="col-xs-12 task-card-foot">
          <div className="checkbox">
            <label>
              <input type="checkbox" readOnly aria-label={`Selecionar ${tarefa.descricao}`} />
            </label>
          </div>
          <div className="progress progress-line-info task-card-progress">
            {percentualExtrapolado ? <i className="fa fa-exclamation-triangle" aria-hidden="true" /> : null}
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
        </div>
      </div>
    </div>
  )
}

export function AddTarefaPlaceholder({ etapaId }: { etapaId?: number }) {
  const url =
    etapaId != null ? P3_NAV.card(0, etapaId).adicionarNovaTarefa : P3_NAV.toolbar.adicionarTarefa
  return (
    <div className="item add-tarefa">
      <button type="button" className="btn" onClick={() => goOperador(url)}>
        <i className="fa fa-plus" aria-hidden="true" />
        <span>Adicionar nova tarefa</span>
      </button>
    </div>
  )
}
