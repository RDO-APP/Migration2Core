type EscolherFiltersProps = {
  filtroObra: string
  filtroMunicipio: string
  onFiltroObra: (v: string) => void
  onFiltroMunicipio: (v: string) => void
}

export function EscolherFilters({
  filtroObra,
  filtroMunicipio,
  onFiltroObra,
  onFiltroMunicipio,
}: EscolherFiltersProps) {
  return (
    <div className="escolher-filtros row">
      <div className="col-sm-6">
        <label htmlFor="filtro-obra">Obra</label>
        <input
          id="filtro-obra"
          type="search"
          className="form-control"
          placeholder="Filtrar por nome da obra"
          value={filtroObra}
          onChange={(e) => onFiltroObra(e.target.value)}
        />
      </div>
      <div className="col-sm-6">
        <label htmlFor="filtro-municipio">Município</label>
        <input
          id="filtro-municipio"
          type="search"
          className="form-control"
          placeholder="Filtrar por cidade/UF"
          value={filtroMunicipio}
          onChange={(e) => onFiltroMunicipio(e.target.value)}
        />
      </div>
    </div>
  )
}
