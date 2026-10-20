import { useEffect, useMemo, useState } from 'react'
import { fetchEscolherContext, selecionarObra } from '../api/obrasApi'
import type { ObraListItem } from '../api/equipamentos-api.types'
import { EscolherFilters } from '../components/EscolherFilters'
import { ObraProgressLegend } from '../components/ObraProgressLegend'
import { OperadorShell } from '../components/OperadorShell'
import { WorkCardObra } from '../components/WorkCardObra'
import '../escolher.css'

function normalize(s: string): string {
  return s
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .toLowerCase()
}

function filterObras(obras: ObraListItem[], filtroObra: string, filtroMunicipio: string): ObraListItem[] {
  const qObra = normalize(filtroObra.trim())
  const qMun = normalize(filtroMunicipio.trim())
  return obras.filter((o) => {
    if (qObra && !normalize(o.descricao).includes(qObra)) {
      return false
    }
    if (qMun && !normalize(o.cidadeEstado ?? '').includes(qMun)) {
      return false
    }
    return true
  })
}

export function EscolherPage() {
  const [usuarioNome, setUsuarioNome] = useState<string>()
  const [obras, setObras] = useState<ObraListItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [filtroObra, setFiltroObra] = useState('')
  const [filtroMunicipio, setFiltroMunicipio] = useState('')
  const [selectingId, setSelectingId] = useState<number | null>(null)

  useEffect(() => {
    let cancelled = false
    fetchEscolherContext()
      .then((ctx) => {
        if (cancelled) return
        setUsuarioNome(ctx.usuarioNome)
        setObras(ctx.obras ?? [])
      })
      .catch((e: unknown) => {
        if (!cancelled) {
          setError(e instanceof Error ? e.message : 'Falha ao carregar obras.')
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [])

  const obrasFiltradas = useMemo(
    () => filterObras(obras, filtroObra, filtroMunicipio),
    [obras, filtroObra, filtroMunicipio],
  )

  async function handleSelect(idObra: number) {
    setSelectingId(idObra)
    setError(null)
    try {
      const res = await selecionarObra(idObra)
      window.location.assign(res.redirectUrl ?? '/Tarefa/Cards')
    } catch (e: unknown) {
      setSelectingId(null)
      setError(e instanceof Error ? e.message : 'Erro ao selecionar obra.')
    }
  }

  if (loading) {
    return (
      <OperadorShell usuarioNome={usuarioNome}>
        <div className="escolher-page container">
          <p className="muted escolher-loading">Carregando obras…</p>
        </div>
      </OperadorShell>
    )
  }

  return (
    <OperadorShell usuarioNome={usuarioNome}>
      <section className="escolher-page container">
        <h2>Selecione uma das obras abaixo:</h2>

        {error ? (
          <div className="alert alert-danger text-center mb-3" role="alert">
            {error}
          </div>
        ) : null}

        {obras.length > 0 ? (
          <EscolherFilters
            filtroObra={filtroObra}
            filtroMunicipio={filtroMunicipio}
            onFiltroObra={setFiltroObra}
            onFiltroMunicipio={setFiltroMunicipio}
          />
        ) : null}

        <div className="lista-obras">
          {obrasFiltradas.length === 0 ? (
            <label className="col-xs-12 no-padding escolher-empty">
              {obras.length === 0
                ? 'Você não está associado a nenhuma obra. Entre em contato com o administrador.'
                : 'Nenhuma obra corresponde aos filtros.'}
            </label>
          ) : (
            obrasFiltradas.map((obra) => (
              <WorkCardObra
                key={obra.idObra}
                obra={obra}
                disabled={selectingId != null}
                onSelect={handleSelect}
              />
            ))
          )}
        </div>

        {obras.length > 0 ? <ObraProgressLegend /> : null}
      </section>
    </OperadorShell>
  )
}
