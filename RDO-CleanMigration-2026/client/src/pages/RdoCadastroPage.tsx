import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
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
  RdoCadastroTarefa,
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

function brDateToIso(br: string): string {
  const m = br.match(/^(\d{2})\/(\d{2})\/(\d{4})$/)
  if (!m) return ''
  return `${m[3]}-${m[2]}-${m[1]}`
}

function isoDateToBr(iso: string): string {
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})$/)
  if (!m) return ''
  return `${m[3]}/${m[2]}/${m[1]}`
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

function ClimaPeriodCol({
  iconClass,
  label,
  name,
  value,
  onChange,
  options,
}: {
  iconClass: string
  label: string
  name: string
  value: ClimaChoice | ChuvaChoice
  onChange: (v: string) => void
  options: ReadonlyArray<{ v: string; text: string }>
}) {
  return (
    <div className="col-sm-4 col-xs-12 rdo-clima-period">
      <label className="control-label rdo-clima-period-label">
        <i className={iconClass} aria-hidden="true" />
        {label}
      </label>
      {options.map(({ v, text }) => (
        <div className="radio" key={v}>
          <label>
            <input
              type="radio"
              name={name}
              checked={value === v}
              onChange={() => onChange(v)}
            />
            {text}
          </label>
        </div>
      ))}
    </div>
  )
}

function ImprodToggle({
  label,
  checked,
  onChange,
}: {
  label: string
  checked: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <div className="togglebutton col-md-15 col-sm-4">
      <label>
        {label}
        <input type="checkbox" checked={checked} onChange={(e) => onChange(e.target.checked)} />
        <span className="toggle" />
      </label>
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
  const [openFotoTarefas, setOpenFotoTarefas] = useState<Set<number>>(() => new Set())
  const [mostrarFotos, setMostrarFotos] = useState(false)
  const [selectedImagens, setSelectedImagens] = useState<Set<number>>(() => new Set())
  const [modalTarefa, setModalTarefa] = useState<RdoCadastroTarefa | null>(null)
  const [fotoAmpliada, setFotoAmpliada] = useState<string | null>(null)
  const [obraFinalizada, setObraFinalizada] = useState(false)
  const [loading, setLoading] = useState(true)
  const [loadingTarefas, setLoadingTarefas] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const datePickerRef = useRef<HTMLInputElement>(null)

  const obraNome = shell?.obraNome
  const improdRow1 = IMPRO_MOTIVOS.slice(0, 5)
  const improdRow2 = IMPRO_MOTIVOS.slice(5)

  const tarefaById = useMemo(() => {
    const map = new Map<number, RdoCadastroTarefa>()
    for (const e of etapas) {
      for (const t of e.tarefas) {
        map.set(t.id, t)
      }
    }
    return map
  }, [etapas])

  const acordeonTarefas = useMemo(() => {
    const list: RdoCadastroTarefa[] = []
    for (const id of selected) {
      const t = tarefaById.get(id)
      if (t) list.push(t)
    }
    return list
  }, [selected, tarefaById])

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
      setOpenEtapas(new Set(data.etapas.length > 0 ? [data.etapas[0].id] : []))
      setSelected(new Set())
      setSelectedImagens(new Set())
      setOpenFotoTarefas(new Set())
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

  function toggleEtapaOpen(id: number) {
    setOpenEtapas((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  function toggleFotoTarefaOpen(id: number) {
    setOpenFotoTarefas((prev) => {
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

  function toggleImagem(idImagem: number, checked: boolean) {
    setSelectedImagens((prev) => {
      const next = new Set(prev)
      if (checked) next.add(idImagem)
      else next.delete(idImagem)
      return next
    })
  }

  function selectAllImagensTarefa(tarefa: RdoCadastroTarefa, marcar: boolean) {
    const imgs = tarefa.listaImagem ?? []
    setSelectedImagens((prev) => {
      const next = new Set(prev)
      for (const img of imgs) {
        if (marcar) next.add(img.idImagem)
        else next.delete(img.idImagem)
      }
      return next
    })
  }

  function tarefaTodasImagensSelecionadas(tarefa: RdoCadastroTarefa): boolean {
    const imgs = tarefa.listaImagem ?? []
    if (imgs.length === 0) return false
    return imgs.every((img) => selectedImagens.has(img.idImagem))
  }

  function setImprodFlag(key: (typeof IMPRO_MOTIVOS)[number]['key'], checked: boolean) {
    setImprod((prev) => ({ ...prev, [key]: checked }))
  }

  function onNativeDateChange(iso: string) {
    if (!iso) return
    const br = isoDateToBr(iso)
    setDataRdo(br)
    void loadEtapas(br)
  }

  function openDatePicker() {
    const el = datePickerRef.current
    if (!el) return
    try {
      el.showPicker()
    } catch {
      el.focus()
      el.click()
    }
  }

  async function postSave(extra: Partial<RdoCadastroSaveRequest>) {
    const body: RdoCadastroSaveRequest = {
      dataRdo,
      climaManha: isClima(climaManha) ? climaManha : '',
      climaTarde: isClima(climaTarde) ? climaTarde : '',
      climaNoite: isClima(climaNoite) ? climaNoite : '',
      chuvaManha: isChuva(chuvaManha) ? chuvaManha : '',
      chuvaTarde: isChuva(chuvaTarde) ? chuvaTarde : '',
      chuvaNoite: isChuva(chuvaNoite) ? chuvaNoite : '',
      comentario: comentario.trim() || undefined,
      tipoComentarioGeracao,
      ...improd,
      listaTarefas: [...selected].map((id) => ({ id })),
      listaImagems: [...selectedImagens].map((idImagem) => ({ idImagem })),
      gerarRelatorioFotografico: mostrarFotos,
      ...extra,
    }
    return saveRdoCadastro(body)
  }

  async function onSalvar() {
    if (!dataRdo.trim()) {
      setError('A data deve ser preenchida.')
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

  const dataIso = brDateToIso(dataRdo)

  return shellWrap(
    <div className="rdo-cadastro-page">
      <div className="panel-heading">
        <h3>Gerar RDO</h3>
      </div>

      <div className="panel rdo-panel-bloco1">
        <div className="col-md-4 col-sm-6 rdo-date-field">
          <div className="form-group">
            <label className="control-label rdo-bloco1-label">
              Data<span className="rdo-required">*</span>
            </label>
            <div className="rdo-date-wrap">
              <input
                type="text"
                className="form-control datepicker-here dataRdo"
                placeholder="dd/mm/aaaa"
                value={dataRdo}
                onFocus={openDatePicker}
                onClick={openDatePicker}
                onChange={(e) => {
                  const v = maskDateInput(e.target.value)
                  setDataRdo(v)
                  if (v.length >= 10) void loadEtapas(v)
                }}
              />
              <button
                type="button"
                className="btn btn-default rdo-date-open"
                title="Abrir calendário"
                aria-label="Abrir calendário"
                onClick={openDatePicker}
              >
                <i className="fa fa-calendar" aria-hidden="true" />
              </button>
              <input
                ref={datePickerRef}
                type="date"
                className="rdo-date-native-hidden"
                tabIndex={-1}
                aria-hidden="true"
                value={dataIso}
                onChange={(e) => onNativeDateChange(e.target.value)}
              />
            </div>
          </div>
        </div>

        <div className="col-xs-12">
          <span className="control-label rdo-bloco1-label rdo-bloco1-section-title">Clima</span>
        </div>

        <div className="row rdo-clima-cols">
        <div className="col-md-6 col-sm-12">
          <fieldset className="rdo-clima-fieldset">
            <legend className="rdo-bloco1-legend">Tempo:</legend>
            <div className="row rdo-clima-row">
            <ClimaPeriodCol
              iconClass="icon-sunrise"
              label="Manhã"
              name="optClimaManha"
              value={climaManha}
              onChange={(v) => setClimaManha(v as ClimaValor)}
              options={[
                { v: 'b', text: 'Bom' },
                { v: 'r', text: 'Ruim' },
              ]}
            />
            <ClimaPeriodCol
              iconClass="icon-sun"
              label="Tarde:"
              name="optClimaTarde"
              value={climaTarde}
              onChange={(v) => setClimaTarde(v as ClimaValor)}
              options={[
                { v: 'b', text: 'Bom' },
                { v: 'r', text: 'Ruim' },
              ]}
            />
            <ClimaPeriodCol
              iconClass="icon-moon"
              label="Noite:"
              name="optClimaNoite"
              value={climaNoite}
              onChange={(v) => setClimaNoite(v as ClimaValor)}
              options={[
                { v: 'b', text: 'Bom' },
                { v: 'r', text: 'Ruim' },
              ]}
            />
            </div>
          </fieldset>
        </div>

        <div className="col-md-6 col-sm-12">
          <fieldset className="rdo-clima-fieldset">
            <legend className="rdo-bloco1-legend">Chuva:</legend>
            <div className="row rdo-clima-row">
            <ClimaPeriodCol
              iconClass="icon-sunrise"
              label="Manhã"
              name="optChuvaManha"
              value={chuvaManha}
              onChange={(v) => setChuvaManha(v as ChuvaValor)}
              options={[
                { v: 's', text: 'Sem chuva' },
                { v: 'p', text: 'Pouca chuva' },
                { v: 'm', text: 'Muita chuva' },
              ]}
            />
            <ClimaPeriodCol
              iconClass="icon-sun"
              label="Tarde:"
              name="optChuvaTarde"
              value={chuvaTarde}
              onChange={(v) => setChuvaTarde(v as ChuvaValor)}
              options={[
                { v: 's', text: 'Sem chuva' },
                { v: 'p', text: 'Pouca chuva' },
                { v: 'm', text: 'Muita chuva' },
              ]}
            />
            <ClimaPeriodCol
              iconClass="icon-moon"
              label="Noite:"
              name="optChuvaNoite"
              value={chuvaNoite}
              onChange={(v) => setChuvaNoite(v as ChuvaValor)}
              options={[
                { v: 's', text: 'Sem chuva' },
                { v: 'p', text: 'Pouca chuva' },
                { v: 'm', text: 'Muita chuva' },
              ]}
            />
            </div>
          </fieldset>
        </div>
        </div>

        <div className="col-md-12">
          <fieldset className="Lista-toggle rdo-improd-fieldset">
            <legend className="rdo-bloco1-legend">Motivos de Improdutividade</legend>
            <div className="bloco">
              {improdRow1.map(({ key, label }) => (
                <ImprodToggle
                  key={key}
                  label={label}
                  checked={improd[key]}
                  onChange={(c) => setImprodFlag(key, c)}
                />
              ))}
            </div>
            <div className="bloco">
              {improdRow2.map(({ key, label }) => (
                <ImprodToggle
                  key={key}
                  label={label}
                  checked={improd[key]}
                  onChange={(c) => setImprodFlag(key, c)}
                />
              ))}
            </div>
          </fieldset>
        </div>

        <div className="col-md-12 col-sm-12">
          <div className="form-group rdo-comentarios-wrap">
            <label className="control-label rdo-bloco1-label">Comentários</label>
            <div className="input-group">
              <textarea
                className="form-control"
                rows={6}
                maxLength={10000}
                value={comentario}
                onChange={(e) => setComentario(e.target.value)}
              />
              <div className="input-group-addon rdo-comentarios-addon">
                <div className="rdo-thumb-inner">
                <button
                  type="button"
                  className="btn btn-transparent rdo-thumb-btn"
                  title="Positivo"
                  aria-pressed={tipoComentarioGeracao === 1}
                  onClick={() => setTipoComentarioGeracao(1)}
                >
                  {tipoComentarioGeracao === 1 ? (
                    <i className="fa fa-thumbs-up" aria-hidden="true" />
                  ) : (
                    <i className="fa fa-thumbs-o-up" aria-hidden="true" />
                  )}
                </button>
                <button
                  type="button"
                  className="btn btn-transparent rdo-thumb-btn"
                  title="Negativo"
                  aria-pressed={tipoComentarioGeracao === 2}
                  onClick={() => setTipoComentarioGeracao(2)}
                >
                  {tipoComentarioGeracao === 2 ? (
                    <i className="fa fa-thumbs-down" aria-hidden="true" />
                  ) : (
                    <i className="fa fa-thumbs-o-down" aria-hidden="true" />
                  )}
                </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="lista-tarefas">
        <div className="col-xs-12 no-padding header-table">
          <h4>ETAPAS / TAREFAS</h4>
          {etapas.length > 0 ? (
            <div className="habilitar">
              <label>Habilitar relatório fotográfico?</label>
              <div className="radio">
                <label>
                  <input
                    type="radio"
                    name="mostrarFotos"
                    checked={mostrarFotos === true}
                    onChange={() => setMostrarFotos(true)}
                  />
                  Sim
                </label>
              </div>
              <div className="radio">
                <label>
                  <input
                    type="radio"
                    name="mostrarFotos"
                    checked={mostrarFotos === false}
                    onChange={() => setMostrarFotos(false)}
                  />
                  Não
                </label>
              </div>
            </div>
          ) : null}
        </div>

        {loadingTarefas ? <p className="rdo-cadastro-muted col-xs-12">Carregando tarefas…</p> : null}
        {!loadingTarefas && etapas.length === 0 ? (
          <label className="col-xs-12 no-padding">Nenhuma tarefa encontrada.</label>
        ) : null}

        <div className="panel-group accordion">
          {etapas.map((etapa) => {
            if (etapa.tarefas.length === 0) return null
            const open = openEtapas.has(etapa.id)
            const allMarked =
              etapa.tarefas.length > 0 && etapa.tarefas.every((t) => selected.has(t.id))
            return (
              <div key={etapa.id} className="panel panel-default">
                <div className="panel-heading">
                  <h4 className="panel-title expand">
                    <a
                      href="#"
                      className={open ? 'active' : ''}
                      onClick={(e) => {
                        e.preventDefault()
                        toggleEtapaOpen(etapa.id)
                      }}
                    >
                      {etapa.titulo}
                    </a>
                  </h4>
                </div>
                {open ? (
                  <div className="rdo-accordion-body">
                    <div className="panel-body">
                      <div className="tabela table-responsive">
                        <table className="table table-striped table-responsive">
                          <thead>
                            <tr>
                              <th style={{ width: '2%' }}>
                                <div className="checkbox selecionar-tudo-tabela">
                                  <label>
                                    <input
                                      className="newInput"
                                      type="checkbox"
                                      checked={allMarked}
                                      onChange={(e) => selectAllEtapa(etapa, e.target.checked)}
                                    />
                                  </label>
                                </div>
                              </th>
                              <th>DESCRIÇÃO DA TAREFA</th>
                              <th>STATUS</th>
                              <th>QTD. COLABORADORES</th>
                              <th>QTD. EQUIPAMENTOS</th>
                              <th>AÇÕES</th>
                            </tr>
                          </thead>
                          <tbody>
                            {etapa.tarefas.map((t) => (
                              <tr key={t.id}>
                                <td>
                                  <div className="checkbox">
                                    <label>
                                      <input
                                        className="newInput"
                                        type="checkbox"
                                        checked={selected.has(t.id)}
                                        onChange={(e) => toggleTarefa(t.id, e.target.checked)}
                                        id={`ckbTarefa-${t.id}`}
                                      />
                                    </label>
                                  </div>
                                </td>
                                <td>
                                  {t.descricao}
                                  {!t.existeRegistroMedicaoDataRequerida &&
                                  t.existeRegistroMedicaoDiaAnterior ? (
                                    <span
                                      className="rdo-tag-prev"
                                      title="Sem medição nesta data — pode copiar dia anterior"
                                    >
                                      dia anterior
                                    </span>
                                  ) : null}
                                </td>
                                <td>{t.nomeStatus}</td>
                                <td>{t.quantidadeColaboradores}</td>
                                <td>{t.quantidadeEquipamentos}</td>
                                <td>
                                  <button
                                    type="button"
                                    className="btn btn-simple btn-just-icon"
                                    title="Editar Tarefa"
                                    onClick={() => setModalTarefa(t)}
                                  >
                                    <i className="fa fa-edit" aria-hidden="true" />
                                  </button>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>
                ) : null}
              </div>
            )
          })}
        </div>
      </div>

      {mostrarFotos && acordeonTarefas.length > 0 ? (
        <div className="rdo-fotos-section">
          <div className="col-xs-12 no-padding header-table">
            <h4>Fotos da(s) Tarefa(s)</h4>
          </div>
          <div className="panel-group accordion">
            {acordeonTarefas.map((tarefa) => {
              const open = openFotoTarefas.has(tarefa.id)
              const imgs = tarefa.listaImagem ?? []
              return (
                <div key={tarefa.id} className="panel panel-default">
                  <div className="panel-heading">
                    <h4 className="panel-title expand">
                      <a
                        href="#"
                        className={open ? 'active' : ''}
                        onClick={(e) => {
                          e.preventDefault()
                          toggleFotoTarefaOpen(tarefa.id)
                        }}
                      >
                        {tarefa.descricao}
                      </a>
                    </h4>
                  </div>
                  {open ? (
                    <div className="rdo-accordion-body">
                      <div className="panel-body">
                        {imgs.length === 0 ? (
                          <div className="rdo-galeria-empty">Nenhuma foto adicionada nesta tarefa.</div>
                        ) : (
                          <>
                            <div className="checkbox rdo-galeria-selecionar-tudo">
                              <label>
                                <input
                                  type="checkbox"
                                  className="newInput"
                                  checked={tarefaTodasImagensSelecionadas(tarefa)}
                                  onChange={(e) => selectAllImagensTarefa(tarefa, e.target.checked)}
                                />
                                SELECIONAR TUDO
                              </label>
                            </div>
                            <section className="galeria rdo-galeria">
                              {imgs.map((imagem) => (
                                <div className="checkbox rdo-galeria-item" key={imagem.idImagem}>
                                  <label>
                                    <input
                                      type="checkbox"
                                      className="newInput rdo-galeria-check"
                                      id={`ckbImagem-${imagem.idImagem}`}
                                      checked={selectedImagens.has(imagem.idImagem)}
                                      onChange={(e) => toggleImagem(imagem.idImagem, e.target.checked)}
                                    />
                                    <img
                                      src={imagem.dsCaminho}
                                      alt=""
                                      loading="lazy"
                                      onError={(e) => {
                                        e.currentTarget.style.visibility = 'hidden'
                                      }}
                                    />
                                    <button
                                      type="button"
                                      title="AMPLIAR"
                                      className="btn btn-blue rdo-galeria-ampliar"
                                      onClick={(e) => {
                                        e.preventDefault()
                                        e.stopPropagation()
                                        setFotoAmpliada(imagem.dsCaminho)
                                      }}
                                    >
                                      <i className="fa fa-search" aria-hidden="true" />
                                    </button>
                                  </label>
                                </div>
                              ))}
                            </section>
                          </>
                        )}
                      </div>
                    </div>
                  ) : null}
                </div>
              )
            })}
          </div>
        </div>
      ) : null}

      {error ? <div className="rdo-error">{error}</div> : null}

      <div className="col-md-12 col-xs-12 rdo-cadastro-footer">
        <div className="pull-right">
          <button
            type="button"
            className="btn btn-blue"
            onClick={() => goOperador(P3_NAV.header.rdoListagem)}
          >
            <i className="fa fa-arrow-left" aria-hidden="true" /> VOLTAR
          </button>
          <button
            type="button"
            className="btn btn-blue"
            disabled={obraFinalizada || saving}
            onClick={() => void onSalvar()}
          >
            <i className="fa fa-save" aria-hidden="true" /> {saving ? 'Salvando…' : 'GERAR RDO'}
          </button>
        </div>
      </div>

      {modalTarefa ? (
        <div
          className="rdo-modal-backdrop"
          role="presentation"
          onClick={() => setModalTarefa(null)}
          onKeyDown={(e) => e.key === 'Escape' && setModalTarefa(null)}
        >
          <div
            className="rdo-modal-dialog"
            role="dialog"
            aria-modal="true"
            onClick={(e) => e.stopPropagation()}
          >
            <h4>TAREFA</h4>
            <p>
              <strong>Descrição:</strong> {modalTarefa.descricao}
            </p>
            <p>
              <strong>Status:</strong> {modalTarefa.nomeStatus}
            </p>
            <p>
              <strong>Colaboradores / equipamentos:</strong> {modalTarefa.quantidadeColaboradores} /{' '}
              {modalTarefa.quantidadeEquipamentos}
            </p>
            <div className="pull-right" style={{ display: 'flex', gap: 8 }}>
              <button type="button" className="btn btn-default" onClick={() => setModalTarefa(null)}>
                Fechar
              </button>
              <a className="btn btn-blue" href={`/Tarefa/Cadastro?id=${modalTarefa.id}`}>
                Abrir cadastro
              </a>
            </div>
          </div>
        </div>
      ) : null}

      {fotoAmpliada ? (
        <div
          className="rdo-modal-backdrop"
          role="presentation"
          onClick={() => setFotoAmpliada(null)}
        >
          <div className="rdo-modal-dialog" onClick={(e) => e.stopPropagation()}>
            <img src={fotoAmpliada} alt="" style={{ maxWidth: '100%' }} />
            <button type="button" className="btn btn-default" onClick={() => setFotoAmpliada(null)}>
              Fechar
            </button>
          </div>
        </div>
      ) : null}
    </div>,
  )
}
