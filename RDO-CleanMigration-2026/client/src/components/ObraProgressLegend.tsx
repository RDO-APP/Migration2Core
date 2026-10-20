export function ObraProgressLegend() {
  return (
    <div className="col-xs-12 no-padding area-legenda">
      <div>
        <label>BARRA DE PROGRESSO DA OBRA:</label>
        <div className="legenda">
          <i className="status bg-verde" aria-hidden />
          <small>OBRA COM PRAZO ESTIMADO ATINGIDO</small>
        </div>
        <div className="legenda">
          <i className="status bg-vermelho" aria-hidden />
          <small>OBRA COM PRAZO ESTIMADO ULTRAPASSADO</small>
        </div>
        <div className="legenda">
          <i className="status bg-cinza" aria-hidden />
          <small>OBRA EM ANDAMENTO</small>
        </div>
      </div>
    </div>
  )
}
