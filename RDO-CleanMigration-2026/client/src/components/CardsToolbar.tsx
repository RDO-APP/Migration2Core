import type { CardsFiltroState } from '../cardsFiltro'
import { STATUS_FILTRO } from '../cardsFiltro'
import { maskDateInput } from '../tarefaCadastroShared'

type EtapaOpt = { id: number; titulo: string }

type CardsToolbarProps = {
  filtroOpen: boolean
  onToggleFiltro: () => void
  onNovaTarefa: () => void
  onNovaEtapa: () => void
  onLista: () => void
  viewToggle?: "lista" | "cards"
  onGerarRdo: () => void
  onEfetivoDiario: () => void
  onEditarObra: () => void
  showGerarRdo?: boolean
  showEditarObra?: boolean
  showCriarNovoTarefa?: boolean
  showCriarNovaEtapa?: boolean
  filtroDraft: CardsFiltroState
  onFiltroDraftChange: (next: CardsFiltroState) => void
  onPesquisarFiltro: () => void
  etapasOpts: EtapaOpt[]
}

/** M4.5 / M4.7c / M7 filtro — paridade cards.html. */
export function CardsToolbar({
  filtroOpen,
  onToggleFiltro,
  onNovaTarefa,
  onNovaEtapa,
  onLista,
  viewToggle = "cards",
  onGerarRdo,
  onEfetivoDiario,
  onEditarObra,
  showGerarRdo = false,
  showEditarObra = false,
  showCriarNovoTarefa = false,
  showCriarNovaEtapa = false,
  filtroDraft,
  onFiltroDraftChange,
  onPesquisarFiltro,
  etapasOpts,
}: CardsToolbarProps) {
  function setField<K extends keyof CardsFiltroState>(key: K, value: CardsFiltroState[K]) {
    onFiltroDraftChange({ ...filtroDraft, [key]: value })
  }

  return (
    <>
      <div className="panel-heading cards-toolbar-heading">
        <h3>Etapas / Tarefas</h3>
        <div className="action pull-right cards-toolbar-heading-actions">
          {showGerarRdo ? (
            <button
              type="button"
              className="btn btn-simple cards-toolbar-primary-action"
              title="Gerar RDO"
              onClick={onGerarRdo}
            >
              <i className="icon-rdo-gerar-novo" aria-hidden />
            </button>
          ) : null}
          {showEditarObra ? (
            <button
              type="button"
              className="btn btn-simple cards-toolbar-primary-action"
              title="Editar Obra"
              onClick={onEditarObra}
            >
              <i className="fa fa-edit" aria-hidden />
            </button>
          ) : null}
          <button
            type="button"
            className="btn btn-simple cards-toolbar-primary-action"
            title="Efetivo Diário"
            onClick={onEfetivoDiario}
          >
            <i className="fa fa-list-alt" aria-hidden />
          </button>
          <button
            type="button"
            className="btn btn-simple btn-view btn-card cards-toolbar-mobile-only"
            title="Lista"
            onClick={onLista}
          >
            <i className="fa fa-columns" aria-hidden />
          </button>
          {showCriarNovoTarefa ? (
            <button
              type="button"
              className="btn btn-simple cards-toolbar-mobile-only"
              title="Adicionar tarefa"
              onClick={onNovaTarefa}
            >
              <i className="fa fa-clipboard" aria-hidden />
            </button>
          ) : null}
          {showCriarNovaEtapa ? (
            <button
              type="button"
              className="btn btn-simple cards-toolbar-mobile-only"
              title="Adicionar etapa"
              onClick={onNovaEtapa}
            >
              <i className="fa fa-file-o" aria-hidden />
            </button>
          ) : null}
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
            <i className={viewToggle === "lista" ? "fa fa-table" : "fa fa-columns"} aria-hidden />
            <span>{viewToggle === "lista" ? "CARDS" : "LISTA"}</span>
          </button>
        </div>
        <div className="cards-toolbar-row-right">
          <button type="button" className="btn btn-dark-blue" onClick={onToggleFiltro}>
            <i className="fa fa-filter" aria-hidden />
            FILTRO
          </button>
          {showCriarNovoTarefa ? (
            <button type="button" className="btn btn-blue" onClick={onNovaTarefa}>
              <i className="fa fa-clipboard" aria-hidden />
              ADICIONAR TAREFA
            </button>
          ) : null}
          {showCriarNovaEtapa ? (
            <button type="button" className="btn btn-blue" onClick={onNovaEtapa}>
              <i className="fa fa-file-o" aria-hidden />
              ADICIONAR ETAPA
            </button>
          ) : null}
        </div>
      </div>

      {filtroOpen ? (
        <div className="col-xs-12 filtro no-padding cards-filtro">
          <div className="panel">
            <div className="cards-filtro-grid">
              <div className="form-group">
                <label className="control-label">Descrição</label>
                <input
                  type="text"
                  className="form-control"
                  value={filtroDraft.descricao}
                  onChange={(e) => setField('descricao', e.target.value)}
                />
              </div>
              <div className="form-group">
                <label className="control-label">Data Inicial Planejada</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="__/__/____"
                  value={filtroDraft.dataInicial}
                  onChange={(e) => setField('dataInicial', maskDateInput(e.target.value))}
                />
              </div>
              <div className="form-group">
                <label className="control-label">Data Final Planejada</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="__/__/____"
                  value={filtroDraft.dataFinalPlanejada}
                  onChange={(e) => setField('dataFinalPlanejada', maskDateInput(e.target.value))}
                />
              </div>
              <div className="form-group">
                <label className="control-label">Status</label>
                <select
                  className="form-control"
                  value={filtroDraft.statusTarefa || ''}
                  onChange={(e) => setField('statusTarefa', Number(e.target.value) || 0)}
                >
                  <option value="">Todos</option>
                  {STATUS_FILTRO.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.nome}
                    </option>
                  ))}
                </select>
              </div>
              <div className="form-group">
                <label className="control-label">Data Inicial Executada</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="__/__/____"
                  value={filtroDraft.dataInicialExecutada}
                  onChange={(e) => setField('dataInicialExecutada', maskDateInput(e.target.value))}
                />
              </div>
              <div className="form-group">
                <label className="control-label">Data Final Executada</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="__/__/____"
                  value={filtroDraft.dataFinalExecutada}
                  onChange={(e) => setField('dataFinalExecutada', maskDateInput(e.target.value))}
                />
              </div>
              <div className="form-group">
                <label className="control-label">Etapa</label>
                <select
                  className="form-control"
                  value={filtroDraft.idEtapa || ''}
                  onChange={(e) => setField('idEtapa', Number(e.target.value) || 0)}
                >
                  <option value="">Todas</option>
                  {etapasOpts.map((e) => (
                    <option key={e.id} value={e.id}>
                      {e.titulo}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <div className="cards-filtro-actions">
              <button type="button" className="btn btn-blue" onClick={onPesquisarFiltro}>
                <i className="fa fa-search" aria-hidden />
                PESQUISAR
              </button>
            </div>
          </div>
        </div>
      ) : null}
    </>
  )
}
