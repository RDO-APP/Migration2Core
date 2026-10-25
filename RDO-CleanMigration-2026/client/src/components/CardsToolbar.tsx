type CardsToolbarProps = {
  filtroOpen: boolean
  onToggleFiltro: () => void
  onNovaTarefa: () => void
  onNovaEtapa: () => void
  onLista: () => void
  onGerarRdo: () => void
  onEfetivoDiario: () => void
  onEditarObra: () => void
}

/** M4.5 / M4.7c — paridade cards.html (ícones linha título + faixa LISTA/FILTRO). */
export function CardsToolbar({
  filtroOpen,
  onToggleFiltro,
  onNovaTarefa,
  onNovaEtapa,
  onLista,
  onGerarRdo,
  onEfetivoDiario,
  onEditarObra,
}: CardsToolbarProps) {
  return (
    <>
      <div className="panel-heading cards-toolbar-heading">
        <h3>Etapas / Tarefas</h3>
        <div className="action pull-right cards-toolbar-heading-actions">
          {/* Prod desktop: RDO · editar obra · efetivo (sem .fadeout) */}
          <button type="button" className="btn btn-simple" title="Gerar RDO" onClick={onGerarRdo}>
            <i className="icon-rdo-gerar-novo" aria-hidden />
          </button>
          <button type="button" className="btn btn-simple" title="Editar Obra" onClick={onEditarObra}>
            <i className="fa fa-edit" aria-hidden />
          </button>
          <button type="button" className="btn btn-simple" title="Efetivo Diário" onClick={onEfetivoDiario}>
            <i className="fa fa-list-alt" aria-hidden />
          </button>
          {/* Prod: .fadein-xs.fadeout — só mobile na linha do título */}
          <button
            type="button"
            className="btn btn-simple btn-view btn-card cards-toolbar-mobile-only"
            title="Lista"
            onClick={onLista}
          >
            <i className="fa fa-columns" aria-hidden />
          </button>
          <button
            type="button"
            className="btn btn-simple cards-toolbar-mobile-only"
            title="Adicionar tarefa"
            onClick={onNovaTarefa}
          >
            <i className="fa fa-clipboard" aria-hidden />
          </button>
          <button
            type="button"
            className="btn btn-simple cards-toolbar-mobile-only"
            title="Adicionar etapa"
            onClick={onNovaEtapa}
          >
            <i className="fa fa-file-o" aria-hidden />
          </button>
          <button
            type="button"
            className="btn btn-simple cards-toolbar-mobile-only"
            title="Filtro"
            aria-expanded={filtroOpen}
            onClick={onToggleFiltro}
          >
            <i className="fa fa-filter" aria-hidden />
          </button>
        </div>
      </div>

      <div className="cards-toolbar-row hidden-xs">
        <div className="cards-toolbar-row-left">
          <button type="button" className="btn btn-simple btn-view btn-card" onClick={onLista}>
            <i className="fa fa-columns" aria-hidden />
            <span>LISTA</span>
          </button>
        </div>
        <div className="cards-toolbar-row-right">
          <button type="button" className="btn btn-dark-blue" onClick={onToggleFiltro}>
            <i className="fa fa-filter" aria-hidden />
            FILTRO
          </button>
          <button type="button" className="btn btn-blue" onClick={onNovaTarefa}>
            <i className="fa fa-clipboard" aria-hidden />
            ADICIONAR TAREFA
          </button>
          <button type="button" className="btn btn-blue" onClick={onNovaEtapa}>
            <i className="fa fa-file-o" aria-hidden />
            ADICIONAR ETAPA
          </button>
        </div>
      </div>

      {filtroOpen ? (
        <div className="col-xs-12 filtro no-padding cards-filtro-stub">
          <div className="panel">
            <p className="cards-filtro-msg">
              Filtros avançados — UI prod em M7 (`/Tarefa/Cards?filtro=1`). Enquanto isso, expanda a etapa no accordion.
            </p>
          </div>
        </div>
      ) : null}
    </>
  )
}
