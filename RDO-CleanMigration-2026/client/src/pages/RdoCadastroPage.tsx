import { useCallback, useEffect, useState, type ReactNode } from 'react'
import {
  fetchRdoCadastroBootstrap,
  fetchRdoCadastroEtapas,
  saveRdoCadastro,
} from '../api/rdoApi'
import type {
  ChuvaChoice,
  ChuvaValor,
  ClimaChoice,
  ClimaValor,
  RdoCadastroEtapa,
  RdoCadastroSaveRequest,
} from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import '../cards-page.css'
import '../rdo-cadastro.css'

function maskDateInput(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 8)
  if (digits.length <= 2) return digits
  if (digits.length <= 4) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4)}`
}

function isClima(v: ClimaChoice): v is ClimaValor {
  return v === 'b' || v === 'r'
}

function isChuva(v: ChuvaChoice): v is ChuvaValor {
  return v === 's' || v === 'p' || v === 'm'
}

const IMPRO_MOTIVOS = [
  { key: 'improdutividadeCondicoesClimaticas', label: 'Condições Climáticas' },
  { key: 'improdutividadeMateriais', label: 'Materiais' },
  { key: 'improdutividadeParalizacoes', label: 'Paralizações' },
  { key: 'improdutividadeEquipamentos', label: 'Equipamentos' },
  { key: 'improdutividadeContratante', label: 'Contratante' },
  { key: 'improdutividadeFornecedores', label: 'Fornecedores' },
  { key: 'improdutividadeMaodeObra', label: 'Mão de obra' },
  { key: 'improdutividadeProjeto', label: 'Projeto' },
  { key: 'improdutividadePlanejamento', label: 'Planejamento / Execução' },
  { key: 'improdutividadeAcidente', label: 'Acidente' },
] as const satisfies ReadonlyArray<{
  key: keyof Pick<
    RdoCadastroSaveRequest,
    | 'improdutividadeCondicoesClimaticas'
    | 'improdutividadeMateriais'
    | 'improdutividadeParalizacoes'
    | 'improdutividadeEquipamentos'
    | 'improdutividadeContratante'
    | 'improdutividadeFornecedores'
    | 'improdutividadeMaodeObra'
    | 'improdutividadeProjeto'
    | 'improdutividadePlanejamento'
    | 'improdutividadeAcidente'
  >
  label: string
}>

type ImprodState = Record<(typeof IMPRO_MOTIVOS)[number]['key'], boolean>

function initialImprod(): ImprodState {
  return {
    improdutividadeCondicoesClimaticas: false,
    improdutividadeMateriais: false,
    improdutividadeParalizacoes: false,
    improdutividadeEquipamentos: false,
    improdutividadeContratante: false,
    improdutividadeFornecedores: false,
    improdutividadeMaodeObra: false,
    improdutividadeProjeto: false,
    improdutividadePlanejamento: false,
    improdutividadeAcidente: false,
  }
}

function ClimaGroup({
  label,
  name,
  value,
  onChange,
}: {
  label: string
  name: string
  value: ClimaChoice
  onChange: (v: ClimaValor) => void
}) {
  return (
    <div className="rdo-clima-col">
      <label className="control-label">{label}</label>
      <div className="radio">
        <label>
          <input type="radio" name={name} checked={value === 'b'} onChange={() => onChange('b')} />
          Bom
        </label>
      </div>
      <div className="radio">
        <label>
          <input type="radio" name={name} checked={value === 'r'} onChange={() => onChange('r')} />
          Ruim
        </label>
      </div>
    </div>
  )
}

function ChuvaGroup({
  label,
  name,
  value,
  onChange,
}: {
  label: string
  name: string
  value: ChuvaChoice
  onChange: (v: ChuvaValor) => void
}) {
  return (
    <div className="rdo-clima-col">
      <label className="control-label">{label}</label>
      {(
        [
          ['s', 'Sem chuva'],
          ['p', 'Pouca chuva'],
          ['m', 'Muita chuva'],
        ] as const
      ).map(([v, text]) => (
        <div className="radio" key={v}>
          <label>
            <input type="radio" name={name} checked={value === v} onChange={() => onChange(v)} />
            {text}
          </label>
        </div>
      ))}
    </div>
  )
}

export function RdoCadastroPage() {
  const { shell } = useShellContext()
  const [dataRdo, setDataRdo] = useState('')
  const [climaManha, setClimaManha] = useState<ClimaChoice>('')
  const [climaTarde, setClimaTarde] = useState<ClimaChoice>('')
  const [climaNoite, setClimaNoite] = useState<ClimaChoice>('')
  const [chuvaManha, setChuvaManha] = useState<ChuvaChoice>('')
  const [chuvaTarde, setChuvaTarde] = useState<ChuvaChoice>('')
  const [chuvaNoite, setChuvaNoite] = useState<ChuvaChoice>('')
  const [improd, setImprod] = useState<ImprodState>(() => initialImprod())
  const [comentario, setComentario] = useState('')
  const [tipoComentarioGeracao, setTipoComentarioGeracao] = useState(0)
  const [etapas, setEtapas] = useState<RdoCadastroEtapa[]>([])
  const [selected, setSelected] = useState<Set<number>>(() => new Set())
  const [openEtapas, setOpenEtapas] = useState<Set<number>>(() => new Set())
  const [obraFinalizada, setObraFinalizada] = useState(false)
  const [loading, setLoading] = useState(true)
  const [loadingTarefas, setLoadingTarefas] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const obraNome = shell?.obraNome

  const loadEtapas = useCallback(async (date: string) => {
    if (date.length < 10) {
      setEtapas([])
      setSelected(new Set())
      return
    }
    setLoadingTarefas(true)
    setError(null)
    try {
      const data = await fetchRdoCadastroEtapas(date)
      setEtapas(data.etapas)
      setOpenEtapas(new Set(data.etapas.map((e) => e.id)))
      setSelected(new Set())
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : 'Falha ao carregar tarefas.')
      setEtapas([])
    } finally {
      setLoadingTarefas(false)
    }
  }, [])

  useEffect(() => {
    let cancelled = false
    fetchRdoCadastroBootstrap()
      .then((b) => {
        if (cancelled) return
        setDataRdo(b.dataRdoHoje)
        setObraFinalizada(b.obraFinalizada)
        void loadEtapas(b.dataRdoHoje)
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao iniciar cadastro.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [loadEtapas])

  function toggleEtapa(id: number) {
    setOpenEtapas((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  function toggleTarefa(id: number, checked: boolean) {
    setSelected((prev) => {
      const next = new Set(prev)
      if (checked) next.add(id)
      else next.delete(id)
      return next
    })
  }

  function selectAllEtapa(etapa: RdoCadastroEtapa, marcar: boolean) {
    setSelected((prev) => {
      const next = new Set(prev)
      for (const t of etapa.tarefas) {
        if (marcar) next.add(t.id)
        else next.delete(t.id)
      }
      return next
    })
  }

  function setImprodFlag(key: (typeof IMPRO_MOTIVOS)[number]['key'], checked: boolean) {
    setImprod((prev) => ({ ...prev, [key]: checked }))
  }

  async function postSave(extra: Partial<RdoCadastroSaveRequest>) {
    const body: RdoCadastroSaveRequest = {
      dataRdo,
      climaManha: climaManha as ClimaValor,
      climaTarde: climaTarde as ClimaValor,
      climaNoite: climaNoite as ClimaValor,
      chuvaManha: chuvaManha as ChuvaValor,
      chuvaTarde: chuvaTarde as ChuvaValor,
      chuvaNoite: chuvaNoite as ChuvaValor,
      comentario: comentario.trim() || undefined,
      tipoComentarioGeracao,
      ...improd,
      listaTarefas: [...selected].map((id) => ({ id })),
      ...extra,
    }
    return saveRdoCadastro(body)
  }

  async function onSalvar() {
    if (!dataRdo.trim()) {
      setError('A data deve ser preenchida.')
      return
    }
    if (!isClima(climaManha) || !isClima(climaTarde) || !isClima(climaNoite)) {
      setError('Preencha o tempo (manhã, tarde e noite).')
      return
    }
    if (!isChuva(chuvaManha) || !isChuva(chuvaTarde) || !isChuva(chuvaNoite)) {
      setError('Preencha a chuva (manhã, tarde e noite).')
      return
    }
    if (selected.size === 0) {
      setError('Selecione ao menos uma tarefa.')
      return
    }

    setSaving(true)
    setError(null)
    try {
      let confirmSubstituir = false
      let confirmCopiarDiaAnterior = false
      for (let step = 0; step < 4; step++) {
        const result = await postSave({ confirmSubstituir, confirmCopiarDiaAnterior })
        if (result.ok) {
          goOperador(P3_NAV.header.rdoListagem)
          return
        }
        if (result.needsConfirm === 'substituir') {
          const ok = window.confirm(
            `Gerar RDO para ${dataRdo}? Se já existir RDO nesta data, ele será substituído.`,
          )
          if (!ok) return
          confirmSubstituir = true
          continue
        }
        if (result.needsConfirm === 'copiarDiaAnterior') {
          const ok = window.confirm(
            `Não há lançamentos no dia ${dataRdo} para: ${result.confirmDetail ?? ''}. Usar lançamentos do dia anterior?`,
          )
          if (!ok) return
          confirmCopiarDiaAnterior = true
          continue
        }
        setError(result.errorMessage ?? 'Não foi possível salvar o RDO.')
        return
      }
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : 'Falha ao salvar.')
    } finally {
      setSaving(false)
    }
  }

  const shellWrap = (body: ReactNode) => (
    <OperadorShell variant="rdo" obraNome={obraNome} shell={shell}>
      {body}
    </OperadorShell>
  )

  if (loading) {
    return shellWrap(
      <div className="rdo-cadastro-page">
        <p className="rdo-cadastro-muted">Carregando…</p>
      </div>,
    )
  }

  return shellWrap(
    <div className="rdo-cadastro-page">
      <div className="panel-heading">
        <h3>Gerar RDO</h3>
      </div>

      <div className="panel rdo-cadastro-panel">
        <div className="row g-2">
          <div className="col-md-4 col-sm-12">
            <div className="form-group">
              <label className="control-label">
                Data<span className="rdo-required">*</span>
              </label>
              <input
                type="text"
                className="form-control"
                placeholder="dd/mm/aaaa"
                value={dataRdo}
                onChange={(e) => {
                  const v = maskDateInput(e.target.value)
                  setDataRdo(v)
                  if (v.length >= 10) void loadEtapas(v)
                }}
              />
            </div>
          </div>
        </div>

        <h5 className="rdo-section-title">Clima</h5>
        <div className="row">
          <div className="col-md-6">
            <fieldset className="rdo-fieldset">
              <legend>Tempo</legend>
              <div className="rdo-clima-row">
                <ClimaGroup label="Manhã" name="climaManha" value={climaManha} onChange={setClimaManha} />
                <ClimaGroup label="Tarde" name="climaTarde" value={climaTarde} onChange={setClimaTarde} />
                <ClimaGroup label="Noite" name="climaNoite" value={climaNoite} onChange={setClimaNoite} />
              </div>
            </fieldset>
          </div>
          <div className="col-md-6">
            <fieldset className="rdo-fieldset">
              <legend>Chuva</legend>
              <div className="rdo-clima-row">
                <ChuvaGroup label="Manhã" name="chuvaManha" value={chuvaManha} onChange={setChuvaManha} />
                <ChuvaGroup label="Tarde" name="chuvaTarde" value={chuvaTarde} onChange={setChuvaTarde} />
                <ChuvaGroup label="Noite" name="chuvaNoite" value={chuvaNoite} onChange={setChuvaNoite} />
              </div>
            </fieldset>
          </div>
        </div>

        <fieldset className="rdo-fieldset rdo-improd-fieldset">
          <legend>Motivos de Improdutividade</legend>
          <div className="rdo-improd-grid">
            {IMPRO_MOTIVOS.map(({ key, label }) => (
              <div className="rdo-improd-toggle" key={key}>
                <label>
                  <input
                    type="checkbox"
                    checked={improd[key]}
                    onChange={(e) => setImprodFlag(key, e.target.checked)}
                  />
                  {label}
                </label>
              </div>
            ))}
          </div>
        </fieldset>

        <div className="rdo-comentarios-wrap">
          <label className="control-label">Comentários</label>
          <div className="rdo-comentarios-input">
            <textarea
              className="form-control"
              rows={6}
              maxLength={10000}
              value={comentario}
              onChange={(e) => setComentario(e.target.value)}
            />
            <div className="rdo-comentarios-thumbs">
              <button
                type="button"
                className={`btn btn-default btn-sm${tipoComentarioGeracao === 1 ? ' btn-active' : ''}`}
                title="Positivo"
                aria-pressed={tipoComentarioGeracao === 1}
                onClick={() => setTipoComentarioGeracao(1)}
              >
                👍
              </button>
              <button
                type="button"
                className={`btn btn-default btn-sm${tipoComentarioGeracao === 2 ? ' btn-active' : ''}`}
                title="Negativo"
                aria-pressed={tipoComentarioGeracao === 2}
                onClick={() => setTipoComentarioGeracao(2)}
              >
                👎
              </button>
            </div>
          </div>
        </div>

        <h5 className="rdo-section-title">Tarefas</h5>
        {loadingTarefas ? <p className="rdo-cadastro-muted">Carregando tarefas…</p> : null}
        {!loadingTarefas && etapas.length === 0 ? (
          <p className="rdo-cadastro-muted">Nenhuma tarefa disponível para esta data.</p>
        ) : null}

        <div className="rdo-etapas-accordion">
          {etapas.map((etapa) => {
            const open = openEtapas.has(etapa.id)
            const allMarked = etapa.tarefas.length > 0 && etapa.tarefas.every((t) => selected.has(t.id))
            return (
              <div key={etapa.id} className="rdo-etapa-block">
                <button type="button" className="rdo-etapa-head" onClick={() => toggleEtapa(etapa.id)}>
                  <span>{open ? '▼' : '▶'}</span> {etapa.titulo}
                </button>
                {open ? (
                  <div className="rdo-etapa-body">
                    <div className="rdo-etapa-actions">
                      <button
                        type="button"
                        className="btn btn-blue btn-sm"
                        onClick={() => selectAllEtapa(etapa, !allMarked)}
                      >
                        {allMarked ? 'Desmarcar etapa' : 'Marcar etapa'}
                      </button>
                    </div>
                    <ul className="rdo-tarefa-list">
                      {etapa.tarefas.map((t) => (
                        <li key={t.id}>
                          <label>
                            <input
                              type="checkbox"
                              checked={selected.has(t.id)}
                              onChange={(e) => toggleTarefa(t.id, e.target.checked)}
                            />
                            {t.descricao}
                            {!t.existeRegistroMedicaoDataRequerida && t.existeRegistroMedicaoDiaAnterior ? (
                              <span className="rdo-tag-prev" title="Sem medição nesta data — pode copiar dia anterior">
                                dia anterior
                              </span>
                            ) : null}
                          </label>
                        </li>
                      ))}
                    </ul>
                  </div>
                ) : null}
              </div>
            )
          })}
        </div>

        {error ? <div className="rdo-error">{error}</div> : null}

        <div className="rdo-cadastro-actions">
          <button type="button" className="btn btn-default" onClick={() => goOperador(P3_NAV.header.rdoListagem)}>
            Voltar
          </button>
          <button
            type="button"
            className="btn btn-blue"
            disabled={obraFinalizada || saving}
            onClick={() => void onSalvar()}
          >
            {saving ? 'Salvando…' : 'SALVAR'}
          </button>
        </div>
      </div>
    </div>,
  )
}
