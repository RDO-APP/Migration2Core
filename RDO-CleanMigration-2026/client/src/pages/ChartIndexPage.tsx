import { useEffect, useMemo, useState } from 'react'
import { fetchGraficoResumo } from '../api/graficoApi'
import type { GraficoResumo } from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { showToast } from '../toast'
import '../cards-page.css'
import '../chart-page.css'

function isoDaysAgo(days: number): string {
  const d = new Date()
  d.setDate(d.getDate() - days)
  return d.toISOString().slice(0, 10)
}

function todayIso(): string {
  return new Date().toISOString().slice(0, 10)
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

function BarList({ items }: { items: { label: string; value: number }[] }) {
  const max = Math.max(1, ...items.map((i) => i.value))
  return (
    <div className="chart-bars">
      {items.map((i) => (
        <div key={i.label} className="chart-bar-row">
          <span>{i.label}</span>
          <div className="chart-bar-track">
            <div className="chart-bar-fill" style={{ width: `${(i.value / max) * 100}%` }} />
          </div>
          <span>{i.value}</span>
        </div>
      ))}
    </div>
  )
}

export function ChartIndexPage() {
  const { shell } = useShellContext()
  const view = chartView()
  const [periodoIni, setPeriodoIni] = useState(isoDaysAgo(30))
  const [periodoFim, setPeriodoFim] = useState(todayIso())
  const [data, setData] = useState<GraficoResumo | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

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
            <button type="button" className="btn btn-default" onClick={() => goOperador('/Chart/Index')}>
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
                  <a href="/chart/rdos" onClick={(e) => { e.preventDefault(); goOperador('/chart/rdos') }}>
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
                  <a href="/chart/diaimprodutivo" onClick={(e) => { e.preventDefault(); goOperador('/chart/diaimprodutivo') }}>
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
                  <a href="/chart/comentario" onClick={(e) => { e.preventDefault(); goOperador('/chart/comentario') }}>
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
                  <a href="/chart/tarefa" onClick={(e) => { e.preventDefault(); goOperador('/chart/tarefa') }}>
                    Ver mais…
                  </a>
                </div>
              </div>
            </div>

            <div className="chart-panel">
              <h4>GESTÃO DE RDO´s</h4>
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
          <div className="chart-panel">
            <h4>RDO´s por obra</h4>
            <BarList
              items={mergedRdos.flatMap((r) => [
                { label: `${r.obr_ds_obra} gerados`, value: r.gerado },
                { label: `${r.obr_ds_obra} atrasados`, value: r.atrasado },
              ])}
            />
          </div>
        ) : view === 'dias' ? (
          <div className="chart-panel">
            <h4>Dias improdutivos</h4>
            <BarList items={data.diasImprodutivos.map((d) => ({ label: d.obr_ds_obra, value: improdutivoTotal(d) }))} />
          </div>
        ) : view === 'comentario' ? (
          <div className="chart-panel">
            <h4>Comentários</h4>
            <BarList
              items={data.comentarios.map((c) => ({
                label: c.obr_ds_obra,
                value: c.positivo_contratada + c.positivo_contratante + c.negativo_contratada + c.negativo_contratante,
              }))}
            />
          </div>
        ) : (
          <div className="chart-panel">
            <h4>Tarefas</h4>
            <BarList items={data.tarefas.map((t) => ({ label: t.obr_ds_obra, value: t.atraso_inicio }))} />
          </div>
        )}
      </div>
    </OperadorShell>
  )
}
