import { useEffect, useMemo, useState } from 'react'
import { fetchGraficoResumo } from '../api/graficoApi'
import type { GraficoResumo } from '../api/equipamentos-api.types'
import { buildGroupedChartSvg } from '../chart/chartExport'
import { ChartExportMenu } from '../components/ChartExportMenu'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

const CHART_PERIODO_KEY = 'rdo-chart-periodo'

function pad2(n: number): string {
  return String(n).padStart(2, '0')
}

function localIso(d: Date): string {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
}

function isoDaysAgo(days: number): string {
  const d = new Date()
  d.setDate(d.getDate() - days)
  return localIso(d)
}

function todayIso(): string {
  return localIso(new Date())
}

function persistPeriodo(ini: string, fim: string) {
  try {
    sessionStorage.setItem(CHART_PERIODO_KEY, JSON.stringify({ ini, fim }))
  } catch {
    /* private mode */
  }
  const url = new URL(window.location.href)
  url.searchParams.set('periodoIni', ini)
  url.searchParams.set('periodoFim', fim)
  window.history.replaceState({}, '', `${url.pathname}${url.search}`)
}

function readPeriodoInicial(): { ini: string; fim: string } {
  const q = new URLSearchParams(window.location.search)
  const qIni = q.get('periodoIni')
  const qFim = q.get('periodoFim')
  if (qIni && qFim) {
    return { ini: qIni, fim: qFim }
  }
  try {
    const raw = sessionStorage.getItem(CHART_PERIODO_KEY)
    if (raw) {
      const p = JSON.parse(raw) as { ini?: string; fim?: string }
      if (p.ini && p.fim) return { ini: p.ini, fim: p.fim }
    }
  } catch {
    /* ignore */
  }
  return { ini: isoDaysAgo(30), fim: todayIso() }
}

function chartUrl(path: string, ini: string, fim: string): string {
  const u = new URL(path, window.location.origin)
  u.searchParams.set('periodoIni', ini)
  u.searchParams.set('periodoFim', fim)
  return u.pathname + u.search
}

function formatBr(iso: string): string {
  const [y, m, d] = iso.split('-')
  if (!y || !m || !d) return iso
  return `${d}/${m}/${y}`
}

function chartView(pathname = window.location.pathname): 'index' | 'rdos' | 'dias' | 'tarefa' | 'comentario' {
  const p = pathname.toLowerCase()
  if (p.includes('/chart/rdos')) return 'rdos'
  if (p.includes('/chart/diaimprodutivo')) return 'dias'
  if (p.includes('/chart/tarefa')) return 'tarefa'
  if (p.includes('/chart/comentario')) return 'comentario'
  return 'index'
}

function improdutivoTotal(d: GraficoResumo['diasImprodutivos'][0]): number {
  return (
    d.imp_clima +
    d.imp_falta_material +
    d.imp_paralizacao +
    d.imp_acidente +
    d.imp_contratante +
    d.imp_equipamento +
    d.imp_fornecedores +
    d.imp_maodeobra +
    d.imp_projeto +
    d.imp_planejamento
  )
}

const RDO_SERIES = [
  { key: 'atrasado', name: 'Atrasados', color: '#254B59' },
  { key: 'assinado_contratada', name: 'Assinados Contratada', color: '#84CCF2' },
  { key: 'assinado_contratante', name: 'Assinados Contratante', color: '#FACD7F' },
  { key: 'gerado', name: 'Gerados', color: '#B5BBA8' },
  { key: 'a_gerar', name: 'A Gerar', color: '#59922B' },
] as const

/** Ordem e cores = prod `ConstruirHighChartDiaImprodutivo`. */
const IMP_SERIES = [
  { key: 'imp_clima', name: 'Clima', color: '#254B59' },
  { key: 'imp_falta_material', name: 'Materiais', color: '#92819F' },
  { key: 'imp_paralizacao', name: 'Paralizações', color: '#B5BBA8' },
  { key: 'imp_acidente', name: 'Acidentes', color: '#B8860B' },
  { key: 'imp_contratante', name: 'Contratante', color: '#FF7F50' },
  { key: 'imp_maodeobra', name: 'Mão de Obra', color: '#FACD7F' },
  { key: 'imp_projeto', name: 'Projeto', color: '#59922B' },
  { key: 'imp_planejamento', name: 'Planejamento', color: '#8A2BE2' },
  { key: 'imp_fornecedores', name: 'Fornecedores', color: '#84CCF2' },
  { key: 'imp_equipamento', name: 'Equipamento', color: '#00FFFF' },
] as const

/** Prod `ConstruirHighchartComentario`. */
const COM_SERIES = [
  { key: 'positivo_contratada', name: 'Positivos Contratada', color: '#254B59' },
  { key: 'positivo_contratante', name: 'Positivos Contratante', color: '#84CCF2' },
  { key: 'negativo_contratada', name: 'Negativos Contratada', color: '#92819F' },
  { key: 'negativo_contratante', name: 'Negativos Contratante', color: '#FACD7F' },
] as const

/** Prod `ConstruirHighChartTarefa`. */
const TAR_SERIES = [
  { key: 'canceladas', name: 'Canceladas', color: '#254B59' },
  { key: 'pausadas', name: 'Pausadas', color: '#84CCF2' },
  { key: 'atraso_inicio', name: 'Início em Atraso', color: '#92819F' },
  { key: 'atraso_fim', name: 'Fim em Atraso', color: '#FACD7F' },
  { key: 'planejada', name: 'Planejada', color: '#B5BBA8' },
  { key: 'em_execucao', name: 'Em Execução', color: '#59922B' },
  { key: 'finalizada', name: 'Finalizada', color: '#00FFFF' },
] as const

type RdoSerieKey = (typeof RDO_SERIES)[number]['key']
type ImpSerieKey = (typeof IMP_SERIES)[number]['key']
type ComSerieKey = (typeof COM_SERIES)[number]['key']
type TarSerieKey = (typeof TAR_SERIES)[number]['key']
type ChartSerieDef = { key: string; name: string; color: string }

type RdoObraBar = {
  obr_ds_obra: string
  atrasado: number
  assinado_contratada: number
  assinado_contratante: number
  gerado: number
  a_gerar: number
}

function rdoExportSvg(rows: RdoObraBar[], visible: Record<RdoSerieKey, boolean>): string {
  return buildGroupedChartSvg(
    "GESTÃO DE RDO's",
    rows.map((r) => ({
      label: r.obr_ds_obra,
      values: {
        atrasado: r.atrasado,
        assinado_contratada: r.assinado_contratada,
        assinado_contratante: r.assinado_contratante,
        gerado: r.gerado,
        a_gerar: r.a_gerar,
      },
    })),
    RDO_SERIES.map((s) => ({ key: s.key, name: s.name, color: s.color })),
    visible,
  )
}

function groupedRowsFrom(
  rows: { obr_ds_obra: string }[],
  series: readonly ChartSerieDef[],
): { label: string; values: Record<string, number> }[] {
  return rows.map((r) => ({
    label: r.obr_ds_obra,
    values: Object.fromEntries(
      series.map((s) => [s.key, Number((r as Record<string, unknown>)[s.key] ?? 0)]),
    ),
  }))
}

function groupedExport(
  title: string,
  rows: { obr_ds_obra: string }[],
  series: readonly ChartSerieDef[],
  visible: Record<string, boolean>,
): string {
  return buildGroupedChartSvg(
    title,
    groupedRowsFrom(rows, series),
    series.map((s) => ({ key: s.key, name: s.name, color: s.color })),
    visible,
  )
}

function impExportSvg(
  rows: GraficoResumo['diasImprodutivos'],
  visible: Record<ImpSerieKey, boolean>,
): string {
  return groupedExport('DIAS IMPRODUTIVOS', rows, IMP_SERIES, visible)
}

function GroupedBars({
  rows,
  series,
  visible,
}: {
  rows: { label: string; values: Record<string, number> }[]
  series: readonly ChartSerieDef[]
  visible: Record<string, boolean>
}) {
  const active = series.filter((s) => visible[s.key])
  const max = Math.max(1, ...rows.flatMap((r) => active.map((s) => Math.max(0, Number(r.values[s.key] ?? 0)))))
  return (
    <div className="chart-grouped">
      {rows.map((row) => (
        <div key={row.label} className="chart-obra-group">
          <div className="chart-obra-name" title={row.label}>
            {row.label}
          </div>
          <div className="chart-obra-bars">
            {active.map((s) => {
              const raw = Number(row.values[s.key] ?? 0)
              const n = Math.max(0, raw)
              const pct = (n / max) * 100
              return (
                <div key={s.key} className="chart-h-bar">
                  <div className="chart-h-track">
                    <div
                      className="chart-h-fill"
                      style={{ width: `${pct}%`, background: s.color }}
                      title={`${s.name}: ${raw}`}
                    />
                  </div>
                  <span className="chart-h-val-out">{raw}</span>
                </div>
              )
            })}
          </div>
        </div>
      ))}
    </div>
  )
}

function SeriesFilter({
  series,
  visible,
  onToggle,
  label,
}: {
  series: readonly ChartSerieDef[]
  visible: Record<string, boolean>
  onToggle: (key: string) => void
  label: string
}) {
  return (
    <div className="chart-series-filter" aria-label={label}>
      {series.map((s) => (
        <label key={s.key}>
          <input type="checkbox" checked={visible[s.key] !== false} onChange={() => onToggle(s.key)} />
          <span className="chart-swatch" style={{ background: s.color }} />
          {s.name}
        </label>
      ))}
    </div>
  )
}

export function ChartIndexPage() {
  const { shell } = useShellContext()
  const view = chartView()
  const inicial = readPeriodoInicial()
  const [periodoIni, setPeriodoIni] = useState(inicial.ini)
  const [periodoFim, setPeriodoFim] = useState(inicial.fim)
  const [data, setData] = useState<GraficoResumo | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [serieOn, setSerieOn] = useState<Record<RdoSerieKey, boolean>>({
    atrasado: true,
    assinado_contratada: true,
    assinado_contratante: true,
    gerado: true,
    a_gerar: true,
  })
  const [impOn, setImpOn] = useState<Record<ImpSerieKey, boolean>>({
    imp_clima: true,
    imp_falta_material: true,
    imp_paralizacao: true,
    imp_acidente: true,
    imp_contratante: true,
    imp_maodeobra: true,
    imp_projeto: true,
    imp_planejamento: true,
    imp_fornecedores: true,
    imp_equipamento: true,
  })
  const [comOn, setComOn] = useState<Record<ComSerieKey, boolean>>({
    positivo_contratada: true,
    positivo_contratante: true,
    negativo_contratada: true,
    negativo_contratante: true,
  })
  const [tarOn, setTarOn] = useState<Record<TarSerieKey, boolean>>({
    canceladas: true,
    pausadas: true,
    atraso_inicio: true,
    atraso_fim: true,
    planejada: true,
    em_execucao: true,
    finalizada: true,
  })

  function goChart(path: string) {
    goOperador(chartUrl(path, periodoIni, periodoFim))
  }

  async function load() {
    if (!periodoIni || !periodoFim) {
      showToast('error', 'Informe Data Início e Data Fim.')
      return
    }
    if (periodoFim < periodoIni) {
      showToast('error', 'Data Fim não pode ser anterior à Data Início.')
      return
    }
    setLoading(true)
    setError(null)
    try {
      const payload = await fetchGraficoResumo(periodoIni, periodoFim)
      setData(payload)
      if (payload.periodoIni && payload.periodoFim) {
        setPeriodoIni(payload.periodoIni)
        setPeriodoFim(payload.periodoFim)
        persistPeriodo(payload.periodoIni, payload.periodoFim)
      }
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Falha ao carregar gráficos.'
      setError(msg)
      showToast('error', msg)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void load()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const mergedRdos = useMemo(() => {
    if (!data) return []
    return data.rdosGerados.map((g) => {
      const a = data.rdosAtrasados.find((x) => x.obr_ds_obra === g.obr_ds_obra)
      return { ...g, atrasado: a?.dias_atraso ?? 0 }
    })
  }, [data])

  const mergedTarefas = useMemo(() => {
    if (!data) return []
    return data.tarefas.map((t) => {
      const st = data.statusTarefas.find((s) => s.obr_ds_obra === t.obr_ds_obra)
      return {
        obr_ds_obra: t.obr_ds_obra,
        canceladas: t.canceladas,
        pausadas: t.pausadas,
        atraso_inicio: t.atraso_inicio,
        atraso_fim: t.atraso_fim,
        planejada: st?.planejada ?? 0,
        em_execucao: st?.em_execucao ?? 0,
        finalizada: st?.finalizada ?? 0,
      }
    })
  }, [data])

  const title =
    view === 'rdos'
      ? "GESTÃO DE RDO's"
      : view === 'dias'
        ? 'DIAS IMPRODUTIVOS'
        : view === 'tarefa'
          ? 'TAREFAS'
          : view === 'comentario'
            ? 'COMENTÁRIOS'
            : 'Dashboard geral'

  return (
    <OperadorShell variant="chart" shell={shell}>
      <div className="chart-page">
        <div className="panel-heading">
          <h3>{title}</h3>
        </div>
        <form
          className="chart-filters"
          onSubmit={(e) => {
            e.preventDefault()
            void load()
          }}
        >
          <div>
            <label htmlFor="chart-periodo-ini">Data Início</label>
            <input
              id="chart-periodo-ini"
              className="form-control"
              type="date"
              value={periodoIni}
              onChange={(e) => setPeriodoIni(e.target.value)}
            />
          </div>
          <div>
            <label htmlFor="chart-periodo-fim">Data Fim</label>
            <input
              id="chart-periodo-fim"
              className="form-control"
              type="date"
              value={periodoFim}
              onChange={(e) => setPeriodoFim(e.target.value)}
            />
          </div>
          <button type="submit" className="btn btn-primary" disabled={loading}>
            Filtrar
          </button>
          {view !== 'index' ? (
            <button type="button" className="btn btn-default" onClick={() => goChart('/Chart/Index')}>
              Voltar
            </button>
          ) : null}
          {data?.periodoIni && data?.periodoFim ? (
            <p className="chart-periodo-aplicado">
              Período aplicado: {formatBr(data.periodoIni)} a {formatBr(data.periodoFim)}
            </p>
          ) : null}
        </form>
        {error ? <p className="text-danger">{error}</p> : null}
        {loading || !data ? (
          <p>Carregando…</p>
        ) : view === 'index' ? (
          <>
            <div className="chart-tiles">
              <div className="chart-tile tile-acqua">
                <h3>RDO´s Atrasados</h3>
                <table>
                  <tbody>
                    {data.rdosAtrasados.map((r) => (
                      <tr key={r.obr_ds_obra}>
                        <td>{r.obr_ds_obra}</td>
                        <td>{r.dias_atraso}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="chart-tile-footer">
                  <a href="/chart/rdos" onClick={(e) => { e.preventDefault(); goChart('/chart/rdos') }}>
                    Ver mais…
                  </a>
                </div>
              </div>
              <div className="chart-tile tile-purple">
                <h3>Dias Improdutivos</h3>
                <table>
                  <tbody>
                    {data.diasImprodutivos.map((d) => (
                      <tr key={d.obr_ds_obra}>
                        <td>{d.obr_ds_obra}</td>
                        <td>{improdutivoTotal(d)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="chart-tile-footer">
                  <a href="/chart/diaimprodutivo" onClick={(e) => { e.preventDefault(); goChart('/chart/diaimprodutivo') }}>
                    Ver mais…
                  </a>
                </div>
              </div>
              <div className="chart-tile tile-darkred">
                <h3>Comentários</h3>
                <table>
                  <tbody>
                    {data.comentarios.map((c) => (
                      <tr key={c.obr_ds_obra}>
                        <td>{c.obr_ds_obra}</td>
                        <td>{c.negativo_contratante}</td>
                        <td>{c.negativo_contratada}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="chart-tile-footer">
                  <a href="/chart/comentario" onClick={(e) => { e.preventDefault(); goChart('/chart/comentario') }}>
                    Ver mais…
                  </a>
                </div>
              </div>
              <div className="chart-tile tile-olive">
                <h3>Tarefas com Início em Atraso</h3>
                <table>
                  <tbody>
                    {data.tarefas.map((t) => (
                      <tr key={t.obr_ds_obra}>
                        <td>{t.obr_ds_obra}</td>
                        <td>{t.atraso_inicio}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                <div className="chart-tile-footer">
                  <a href="/chart/tarefa" onClick={(e) => { e.preventDefault(); goChart('/chart/tarefa') }}>
                    Ver mais…
                  </a>
                </div>
              </div>
            </div>

            <div className="chart-panel">
              <div className="chart-panel-head">
                <h4>GESTÃO DE RDO´s</h4>
                <ChartExportMenu filename="gestao-rdos" getSvg={() => rdoExportSvg(mergedRdos, serieOn)} />
              </div>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Atrasados</th>
                      <th>Assinatura Contratada</th>
                      <th>Assinatura Contratante</th>
                      <th>Gerados</th>
                      <th>A Gerar</th>
                    </tr>
                  </thead>
                  <tbody>
                    {mergedRdos.map((r, i) => (
                      <tr key={r.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{r.obr_ds_obra}</td>
                        <td>{r.atrasado}</td>
                        <td>{r.assinado_contratada}</td>
                        <td>{r.assinado_contratante}</td>
                        <td>{r.gerado}</td>
                        <td>{r.a_gerar}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="chart-panel">
              <h4>DIAS IMPRODUTIVOS</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Clima</th>
                      <th>Fornecedores</th>
                      <th>Materiais</th>
                      <th>Mão de Obra</th>
                      <th>Paralizações</th>
                      <th>Projeto</th>
                      <th>Equipamento</th>
                      <th>Planejamento</th>
                      <th>Contratante</th>
                      <th>Acidentes</th>
                    </tr>
                  </thead>
                  <tbody>
                    {data.diasImprodutivos.map((d, i) => (
                      <tr key={d.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{d.obr_ds_obra}</td>
                        <td>{d.imp_clima}</td>
                        <td>{d.imp_fornecedores}</td>
                        <td>{d.imp_falta_material}</td>
                        <td>{d.imp_maodeobra}</td>
                        <td>{d.imp_paralizacao}</td>
                        <td>{d.imp_projeto}</td>
                        <td>{d.imp_equipamento}</td>
                        <td>{d.imp_planejamento}</td>
                        <td>{d.imp_contratante}</td>
                        <td>{d.imp_acidente}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="chart-panel">
              <h4>COMENTÁRIOS</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Positivos Contratada</th>
                      <th>Positivos Contratante</th>
                      <th>Negativos Contratada</th>
                      <th>Negativos Contratante</th>
                    </tr>
                  </thead>
                  <tbody>
                    {data.comentarios.map((c, i) => (
                      <tr key={c.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{c.obr_ds_obra}</td>
                        <td>{c.positivo_contratada}</td>
                        <td>{c.positivo_contratante}</td>
                        <td>{c.negativo_contratada}</td>
                        <td>{c.negativo_contratante}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="chart-panel">
              <h4>TAREFAS</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Atraso início</th>
                      <th>Atraso fim</th>
                      <th>Pausada</th>
                      <th>Cancelada</th>
                      <th>Planejada</th>
                      <th>Em execução</th>
                      <th>Finalizada</th>
                    </tr>
                  </thead>
                  <tbody>
                    {data.tarefas.map((t, i) => {
                      const st = data.statusTarefas.find((s) => s.obr_ds_obra === t.obr_ds_obra)
                      return (
                        <tr key={t.obr_ds_obra}>
                          <td>{i + 1}</td>
                          <td>{t.obr_ds_obra}</td>
                          <td>{t.atraso_inicio}</td>
                          <td>{t.atraso_fim}</td>
                          <td>{t.pausadas}</td>
                          <td>{t.canceladas}</td>
                          <td>{st?.planejada ?? 0}</td>
                          <td>{st?.em_execucao ?? 0}</td>
                          <td>{st?.finalizada ?? 0}</td>
                        </tr>
                      )
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        ) : view === 'rdos' ? (
          <>
            <SeriesFilter
              label="Séries do gráfico"
              series={RDO_SERIES}
              visible={serieOn}
              onToggle={(key) => setSerieOn((prev) => ({ ...prev, [key]: !prev[key as RdoSerieKey] }))}
            />
            <div className="chart-panel chart-plot">
              <div className="chart-panel-head">
                <h4>RDO´s por obra</h4>
                <ChartExportMenu filename="gestao-rdos" getSvg={() => rdoExportSvg(mergedRdos, serieOn)} />
              </div>
              <GroupedBars
                series={RDO_SERIES}
                visible={serieOn}
                rows={mergedRdos.map((r) => ({
                  label: r.obr_ds_obra,
                  values: {
                    atrasado: r.atrasado,
                    assinado_contratada: r.assinado_contratada,
                    assinado_contratante: r.assinado_contratante,
                    gerado: r.gerado,
                    a_gerar: r.a_gerar,
                  },
                }))}
              />
            </div>
            <div className="chart-panel">
              <h4>Tabela</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Atrasados</th>
                      <th>Assinatura Contratada</th>
                      <th>Assinatura Contratante</th>
                      <th>Gerados</th>
                      <th>A Gerar</th>
                    </tr>
                  </thead>
                  <tbody>
                    {mergedRdos.map((r, i) => (
                      <tr key={r.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{r.obr_ds_obra}</td>
                        <td>{r.atrasado}</td>
                        <td>{r.assinado_contratada}</td>
                        <td>{r.assinado_contratante}</td>
                        <td>{r.gerado}</td>
                        <td>{r.a_gerar}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        ) : view === 'dias' ? (
          <>
            <SeriesFilter
              label="Categorias de dias improdutivos"
              series={IMP_SERIES}
              visible={impOn}
              onToggle={(key) => setImpOn((prev) => ({ ...prev, [key]: !prev[key as ImpSerieKey] }))}
            />
            <div className="chart-panel chart-plot">
              <div className="chart-panel-head">
                <h4>CATEGORIAS</h4>
                <ChartExportMenu filename="dias-improdutivos" getSvg={() => impExportSvg(data.diasImprodutivos, impOn)} />
              </div>
              <GroupedBars
                series={IMP_SERIES}
                visible={impOn}
                rows={data.diasImprodutivos.map((r) => ({
                  label: r.obr_ds_obra,
                  values: Object.fromEntries(IMP_SERIES.map((s) => [s.key, Number(r[s.key] ?? 0)])),
                }))}
              />
            </div>
            <div className="chart-panel">
              <h4>Tabela</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Clima</th>
                      <th>Fornecedores</th>
                      <th>Materiais</th>
                      <th>Mão de Obra</th>
                      <th>Paralizações</th>
                      <th>Projeto</th>
                      <th>Equipamento</th>
                      <th>Planejamento</th>
                      <th>Contratante</th>
                      <th>Acidentes</th>
                    </tr>
                  </thead>
                  <tbody>
                    {data.diasImprodutivos.map((d, i) => (
                      <tr key={d.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{d.obr_ds_obra}</td>
                        <td>{d.imp_clima}</td>
                        <td>{d.imp_fornecedores}</td>
                        <td>{d.imp_falta_material}</td>
                        <td>{d.imp_maodeobra}</td>
                        <td>{d.imp_paralizacao}</td>
                        <td>{d.imp_projeto}</td>
                        <td>{d.imp_equipamento}</td>
                        <td>{d.imp_planejamento}</td>
                        <td>{d.imp_contratante}</td>
                        <td>{d.imp_acidente}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        ) : view === 'comentario' ? (
          <>
            <SeriesFilter
              label="Séries de comentários"
              series={COM_SERIES}
              visible={comOn}
              onToggle={(key) => setComOn((prev) => ({ ...prev, [key]: !prev[key as ComSerieKey] }))}
            />
            <div className="chart-panel chart-plot">
              <div className="chart-panel-head">
                <h4>COMENTÁRIOS</h4>
                <ChartExportMenu
                  filename="comentarios"
                  getSvg={() => groupedExport('COMENTÁRIOS', data.comentarios, COM_SERIES, comOn)}
                />
              </div>
              <GroupedBars series={COM_SERIES} visible={comOn} rows={groupedRowsFrom(data.comentarios, COM_SERIES)} />
            </div>
            <div className="chart-panel">
              <h4>Tabela</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Positivos Contratada</th>
                      <th>Positivos Contratante</th>
                      <th>Negativos Contratada</th>
                      <th>Negativos Contratante</th>
                    </tr>
                  </thead>
                  <tbody>
                    {data.comentarios.map((c, i) => (
                      <tr key={c.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{c.obr_ds_obra}</td>
                        <td>{c.positivo_contratada}</td>
                        <td>{c.positivo_contratante}</td>
                        <td>{c.negativo_contratada}</td>
                        <td>{c.negativo_contratante}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        ) : (
          <>
            <SeriesFilter
              label="Séries de tarefas"
              series={TAR_SERIES}
              visible={tarOn}
              onToggle={(key) => setTarOn((prev) => ({ ...prev, [key]: !prev[key as TarSerieKey] }))}
            />
            <div className="chart-panel chart-plot">
              <div className="chart-panel-head">
                <h4>CATEGORIAS</h4>
                <ChartExportMenu
                  filename="tarefas"
                  getSvg={() => groupedExport('TAREFAS', mergedTarefas, TAR_SERIES, tarOn)}
                />
              </div>
              <GroupedBars series={TAR_SERIES} visible={tarOn} rows={groupedRowsFrom(mergedTarefas, TAR_SERIES)} />
            </div>
            <div className="chart-panel">
              <h4>Tabela</h4>
              <div className="table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Obra</th>
                      <th>Início em atraso</th>
                      <th>Final em atraso</th>
                      <th>Pausadas</th>
                      <th>Canceladas</th>
                      <th>Planejada</th>
                      <th>Em Execução</th>
                      <th>Finalizada</th>
                    </tr>
                  </thead>
                  <tbody>
                    {mergedTarefas.map((t, i) => (
                      <tr key={t.obr_ds_obra}>
                        <td>{i + 1}</td>
                        <td>{t.obr_ds_obra}</td>
                        <td>{t.atraso_inicio}</td>
                        <td>{t.atraso_fim}</td>
                        <td>{t.pausadas}</td>
                        <td>{t.canceladas}</td>
                        <td>{t.planejada}</td>
                        <td>{t.em_execucao}</td>
                        <td>{t.finalizada}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>
    </OperadorShell>
  )
}
