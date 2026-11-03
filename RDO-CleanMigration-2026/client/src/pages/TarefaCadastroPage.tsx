import { useEffect, useMemo, useRef, useState } from 'react'
import { fetchTarefaCadastro, saveTarefaCadastro } from '../api/tarefaApi'
import type {
  TarefaCadastro,
  TarefaCadastroColaborador,
  TarefaCadastroEquipamento,
  TarefaCadastroImagem,
} from '../api/equipamentos-api.types'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import {
  STATUS_PAUSADA,
  STATUS_PLANEJADA,
  buildSaveRequest,
  horimetroTotal,
  maskDateInput,
  statusOptionsFor,
  todayBr,
  validateTarefaForm,
} from '../tarefaCadastroShared'
import '../rdo-cadastro.css'
import '../tarefa-cadastro.css'

function queryFlags() {
  const q = new URLSearchParams(window.location.search)
  const id = Number(q.get('id'))
  return {
    id: Number.isFinite(id) && id > 0 ? id : 0,
    visualizar: q.get('modo') === 'visualizar',
    novaMedicao: q.get('novaMedicao') === '1' || q.get('novaMedicao') === 'true',
  }
}

function dash(v?: string): string {
  const t = v?.trim()
  return t ? t : '—'
}

function tipoAquisicaoLabel(v: string): string {
  if (v === 'C') return 'Compra'
  if (v === 'A') return 'Aluguel'
  return '—'
}

function fmtNum(v?: number | null): string {
  if (v == null) return '—'
  return String(v)
}

export function TarefaCadastroPage() {
  const { shell } = useShellContext()
  const flags = useMemo(queryFlags, [])
  const [data, setData] = useState<TarefaCadastro | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  const [descricao, setDescricao] = useState('')
  const [idEtapa, setIdEtapa] = useState(0)
  const [status, setStatus] = useState(0)
  const [idUnidade, setIdUnidade] = useState(0)
  const [dataInicio, setDataInicio] = useState('')
  const [dataPrevisaoFim, setDataPrevisaoFim] = useState('')
  const [qtdPlanejada, setQtdPlanejada] = useState(0)
  const [valor, setValor] = useState(0)
  const [qtdConstruida, setQtdConstruida] = useState(0)
  const [dataMedicao, setDataMedicao] = useState('')
  const [horaInicial, setHoraInicial] = useState('')
  const [horaFinal, setHoraFinal] = useState('')
  const [horimetroInicial, setHorimetroInicial] = useState(0)
  const [horimetroFinal, setHorimetroFinal] = useState(0)
  const [comentario, setComentario] = useState('')
  const [codigoParalizacao, setCodigoParalizacao] = useState('')
  const [colabs, setColabs] = useState<TarefaCadastroColaborador[]>([])
  const [equips, setEquips] = useState<TarefaCadastroEquipamento[]>([])
  const [fotos, setFotos] = useState<TarefaCadastroImagem[]>([])
  const [fotoNome, setFotoNome] = useState('')
  const fileRef = useRef<HTMLInputElement>(null)
  const [modal, setModal] = useState<null | 'historico' | 'colab' | 'equip'>(null)
  const [pickedColab, setPickedColab] = useState<Set<number>>(new Set())
  const [pickedEquip, setPickedEquip] = useState<Set<number>>(new Set())

  const visualizar = flags.visualizar
  const novaMedicao = flags.novaMedicao && !visualizar

  useEffect(() => {
    let cancelled = false
    if (flags.id <= 0) {
      setError('Informe a tarefa.')
      setLoading(false)
      return
    }
    fetchTarefaCadastro(flags.id)
      .then((dto) => {
        if (cancelled) return
        setData(dto)
        setDescricao(dto.descricao)
        setIdEtapa(dto.idEtapa)
        setStatus(dto.status)
        setIdUnidade(dto.idUnidade)
        setDataInicio(dto.dataInicio)
        setDataPrevisaoFim(dto.dataPrevisaoFim)
        setQtdPlanejada(dto.qtdPlanejada)
        setValor(dto.valor)
        setQtdConstruida(novaMedicao ? 0 : dto.qtdConstruida)
        setDataMedicao(novaMedicao ? todayBr() : dto.dataMedicao)
        setHoraInicial(novaMedicao ? '' : dto.horaInicial)
        setHoraFinal(novaMedicao ? '' : dto.horaFinal)
        const hi = novaMedicao ? (dto.ultimoHorimetroFinal ?? dto.horimetroFinal ?? 0) : dto.horimetroInicial
        setHorimetroInicial(hi)
        setHorimetroFinal(novaMedicao ? 0 : dto.horimetroFinal)
        setComentario(novaMedicao ? '' : dto.comentario)
        setCodigoParalizacao(dto.codigoParalizacao ?? '')
        setColabs(dto.listaColaboradores ?? [])
        setEquips(dto.listaEquipamentos ?? [])
        setFotos(dto.listaImagens ?? [])
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar tarefa.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [flags.id, novaMedicao])

  const headerLocked = visualizar || (data != null && data.status !== STATUS_PLANEJADA)
  const medicaoLocked = visualizar || data?.rdoAssinado === true
  const statusOpts = statusOptionsFor(data?.statusTarefa ?? [], data?.status ?? 0, novaMedicao)
  const totalH = horimetroTotal(horimetroInicial, horimetroFinal)
  const showMedicaoAcoes = !novaMedicao && status !== STATUS_PLANEJADA
  const showFoto = status !== STATUS_PLANEJADA

  function openColabModal() {
    setPickedColab(new Set(colabs.map((c) => c.idObraColaborador)))
    setModal('colab')
  }

  function openEquipModal() {
    setPickedEquip(new Set(equips.map((e) => e.idObraEquipamento)))
    setModal('equip')
  }

  function confirmColab() {
    const pool = data?.colaboradoresObra ?? []
    setColabs(pool.filter((c) => pickedColab.has(c.idObraColaborador)))
    setModal(null)
  }

  function confirmEquip() {
    const pool = data?.equipamentosObra ?? []
    setEquips(pool.filter((e) => pickedEquip.has(e.idObraEquipamento)))
    setModal(null)
  }

  function onEscolherFoto(file: File | undefined) {
    if (!file) {
      setFotoNome('')
      return
    }
    if (file.size > 2 * 1024 * 1024) {
      showToast('error', 'O tamanho máximo da imagem é de 2MB.')
      return
    }
    setFotoNome(file.name)
  }

  function onAdicionarFoto() {
    const file = fileRef.current?.files?.[0]
    if (!file) {
      showToast('error', 'Selecione um arquivo.')
      return
    }
    if (file.size > 2 * 1024 * 1024) {
      showToast('error', 'O tamanho máximo da imagem é de 2MB.')
      return
    }
    const href = URL.createObjectURL(file)
    setFotos((prev) => [...prev, { id: -Date.now(), href }])
    setFotoNome('')
    if (fileRef.current) fileRef.current.value = ''
  }

  async function onSave() {
    if (!data) return
    const msg = validateTarefaForm({
      descricao,
      idEtapa,
      status,
      dataInicio,
      dataPrevisaoFim,
      dataMedicao,
      codigoParalizacao,
      novaMedicao,
    })
    if (msg) {
      showToast('error', msg)
      return
    }
    setSaving(true)
    try {
      const result = await saveTarefaCadastro(
        buildSaveRequest(
          data,
          {
            descricao,
            idEtapa,
            status,
            idUnidade,
            dataInicio,
            dataPrevisaoFim,
            qtdPlanejada,
            valor,
            qtdConstruida,
            dataMedicao,
            horaInicial,
            horaFinal,
            horimetroInicial,
            horimetroFinal,
            comentario,
            codigoParalizacao,
            listaIdsObraColaborador: colabs.map((c) => c.idObraColaborador).filter((id) => id > 0),
            listaIdsObraEquipamento: equips.map((e) => e.idObraEquipamento).filter((id) => id > 0),
          },
          novaMedicao,
        ),
      )
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast('success', 'Registro salvo com sucesso.')
      goOperador(P3_NAV.header.tarefaCards)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  const title = visualizar ? 'Visualizar tarefa' : novaMedicao ? 'Nova medição' : 'Tarefa / Medição'

  return (
    <OperadorShell variant="cards" obraNome={shell?.obraNome} shell={shell}>
      <section className="rdo-cadastro-page tarefa-cadastro-page">
        <div className="panel-heading">
          <h3>{title}</h3>
        </div>

        {loading ? <p className="muted">Carregando…</p> : null}
        {error ? <div className="rdo-error">{error}</div> : null}

        {data ? (
          <>
            <form
              id="form-cadastro-tarefa"
              className="panel rdo-panel-bloco1"
              onSubmit={(e) => {
                e.preventDefault()
                void onSave()
              }}
            >
              <div className="row">
                <div className="col-md-8 col-sm-8">
                  <div className="form-group">
                    <label className="control-label">
                      Descrição<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      className="form-control"
                      maxLength={600}
                      value={descricao}
                      disabled={headerLocked}
                      onChange={(e) => setDescricao(e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">
                      Etapa<span style={{ color: 'red' }}>*</span>
                    </label>
                    <select
                      className="form-control"
                      value={idEtapa}
                      disabled={headerLocked}
                      onChange={(e) => setIdEtapa(Number(e.target.value))}
                    >
                      <option value={0}>Selecione...</option>
                      {data.etapas.map((e) => (
                        <option key={e.id} value={e.id}>
                          {e.nome}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">
                      Data Inicial Planejada<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      className="form-control"
                      value={dataInicio}
                      disabled={headerLocked}
                      onChange={(e) => setDataInicio(maskDateInput(e.target.value))}
                      placeholder="__/__/____"
                    />
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">
                      Data Final Planejada<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      className="form-control"
                      value={dataPrevisaoFim}
                      disabled={headerLocked}
                      onChange={(e) => setDataPrevisaoFim(maskDateInput(e.target.value))}
                      placeholder="__/__/____"
                    />
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">Unidade de Medida</label>
                    <select
                      className="form-control"
                      value={idUnidade}
                      disabled={headerLocked}
                      onChange={(e) => setIdUnidade(Number(e.target.value))}
                    >
                      <option value={0}>Selecione...</option>
                      {data.unidades.map((u) => (
                        <option key={u.id} value={u.id}>
                          {u.nome}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">Quantidade Planejada</label>
                    <input
                      className="form-control"
                      type="number"
                      step="0.01"
                      value={qtdPlanejada}
                      disabled={headerLocked}
                      onChange={(e) => setQtdPlanejada(Number(e.target.value))}
                    />
                  </div>
                </div>
                <div className="col-md-4 col-sm-4">
                  <div className="form-group">
                    <label className="control-label">Valor Unitário</label>
                    <div className="tarefa-valor-wrap">
                      <span className="tarefa-valor-prefix">R$</span>
                      <input
                        className="form-control"
                        type="number"
                        step="0.01"
                        value={valor}
                        disabled={headerLocked}
                        onChange={(e) => setValor(Number(e.target.value))}
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div className="col-xs-12 no-padding header-table tarefa-medicao-head">
                <h4>MEDIÇÃO</h4>
                {showMedicaoAcoes ? (
                  <div className="pull-right">
                    <button
                      type="button"
                      className="btn btn-blue btn-block-xs"
                      onClick={() => setModal('historico')}
                    >
                      <i className="fa fa-clock-o" aria-hidden="true" /> HISTÓRICO DE MEDIÇÕES
                    </button>
                    {!visualizar ? (
                      <button
                        type="button"
                        className="btn btn-blue btn-block-xs"
                        onClick={() => goOperador(P3_NAV.card(data.id).novaMedicao)}
                      >
                        <i className="fa fa-plus" aria-hidden="true" /> ADICIONAR MEDIÇÃO
                      </button>
                    ) : null}
                  </div>
                ) : null}
              </div>

              <div className="row">
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">
                      Status<span style={{ color: 'red' }}>*</span>
                    </label>
                    <select
                      className="form-control"
                      value={status}
                      disabled={medicaoLocked}
                      onChange={(e) => setStatus(Number(e.target.value))}
                    >
                      <option value={0}>Selecione...</option>
                      {statusOpts.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.nome}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                {status === STATUS_PAUSADA ? (
                  <div className="col-md-9 col-sm-12">
                    <div className="form-group">
                      <label className="control-label">
                        Código de Paralização<span style={{ color: 'red' }}>*</span>
                      </label>
                      <select
                        className="form-control"
                        value={codigoParalizacao}
                        disabled={medicaoLocked}
                        onChange={(e) => setCodigoParalizacao(e.target.value)}
                      >
                        <option value="">Selecione...</option>
                        {data.codigosParalizacao.map((c) => (
                          <option key={c.codigo} value={c.codigo}>
                            {c.codigo} - {c.descricao}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                ) : null}
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">
                      Data<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      className="form-control"
                      value={dataMedicao}
                      disabled={medicaoLocked}
                      onChange={(e) => setDataMedicao(maskDateInput(e.target.value))}
                      placeholder="__/__/____"
                    />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Hora Inicial</label>
                    <input
                      className="form-control"
                      type="time"
                      value={horaInicial}
                      disabled={medicaoLocked}
                      onChange={(e) => setHoraInicial(e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Hora Final</label>
                    <input
                      className="form-control"
                      type="time"
                      value={horaFinal}
                      disabled={medicaoLocked}
                      onChange={(e) => setHoraFinal(e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Quantidade Construída</label>
                    <input
                      className="form-control"
                      type="number"
                      step="0.01"
                      value={qtdConstruida}
                      disabled={medicaoLocked || (status !== 1 && status !== 2 && status !== 3)}
                      onChange={(e) => setQtdConstruida(Number(e.target.value))}
                    />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Horímetro Inicial</label>
                    <input className="form-control" readOnly value={horimetroInicial} disabled={medicaoLocked} />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Horímetro Final</label>
                    <input
                      className="form-control"
                      type="number"
                      step="0.1"
                      value={horimetroFinal}
                      disabled={medicaoLocked}
                      onChange={(e) => setHorimetroFinal(Number(e.target.value))}
                    />
                  </div>
                </div>
                <div className="col-md-3 col-sm-12">
                  <div className="form-group">
                    <label className="control-label">Total Horas</label>
                    <input className="form-control" readOnly value={totalH} disabled={medicaoLocked} />
                  </div>
                </div>
                <div className="col-md-12">
                  <div className="form-group">
                    <label className="control-label">Comentário</label>
                    <textarea
                      className="form-control"
                      maxLength={1400}
                      rows={3}
                      value={comentario}
                      disabled={medicaoLocked}
                      onChange={(e) => setComentario(e.target.value)}
                    />
                  </div>
                </div>
                {showFoto ? (
                  <div className="col-md-12 tarefa-foto-bloco">
                    <label className="control-label">Foto</label>
                    {!visualizar ? (
                      <div className="tarefa-foto-row">
                        <input
                          ref={fileRef}
                          type="file"
                          accept=".png,.jpg,.jpeg,.bmp"
                          className="sr-only"
                          onChange={(e) => onEscolherFoto(e.target.files?.[0])}
                        />
                        <div className="tarefa-foto-file">
                          <i className="fa fa-picture-o" aria-hidden="true" />
                          <input
                            className="form-control"
                            readOnly
                            value={fotoNome}
                            placeholder="Nenhum arquivo selecionado (Tamanho Máx 2mb)"
                          />
                        </div>
                        <button
                          type="button"
                          className="btn btn-blue"
                          onClick={() => fileRef.current?.click()}
                        >
                          ESCOLHER ARQUIVO
                        </button>
                        <button type="button" className="btn btn-blue" onClick={onAdicionarFoto}>
                          <i className="fa fa-picture-o" aria-hidden="true" /> ADICIONAR FOTO
                        </button>
                      </div>
                    ) : null}
                    {fotos.length === 0 ? (
                      visualizar ? <p className="muted">Nenhuma foto nesta medição.</p> : null
                    ) : (
                      <section className="galeria rdo-galeria">
                        {fotos.map((img) => (
                          <div key={img.id} className="rdo-galeria-item">
                            <label>
                              {img.href ? <img src={img.href} alt="" /> : <span className="muted">sem arquivo</span>}
                            </label>
                          </div>
                        ))}
                      </section>
                    )}
                  </div>
                ) : null}
              </div>
            </form>

            <div className="lista-tarefas">
              <div className="col-xs-12 no-padding header-table">
                <h4>COLABORADORES</h4>
                {!visualizar ? (
                  <div className="pull-right">
                    <button type="button" className="btn btn-blue btn-block-xs" disabled={saving} onClick={() => void onSave()}>
                      <i className="fa fa-save" aria-hidden="true" /> SALVAR TAREFA
                    </button>
                    <button type="button" className="btn btn-blue btn-block-xs" onClick={openColabModal}>
                      <i className="fa fa-users" aria-hidden="true" /> ADICIONAR COLABORADOR
                    </button>
                    <button
                      type="button"
                      className="btn btn-blue btn-block-xs"
                      onClick={() => showToast('error', 'Cadastro de novo colaborador da obra ainda não está nesta tela. Use Adicionar colaborador para quem já está na obra.')}
                    >
                      <i className="fa fa-user-plus" aria-hidden="true" /> NOVO COLABORADOR
                    </button>
                  </div>
                ) : null}
              </div>
              <div className="tabela table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>Nome</th>
                      <th>Cargo</th>
                      <th>Telefone</th>
                      <th>E-mail</th>
                      <th>Perfil</th>
                      <th colSpan={2}>AÇÕES</th>
                    </tr>
                  </thead>
                  <tbody>
                    {colabs.length === 0 ? (
                      <tr>
                        <td colSpan={7}>Nenhum registro encontrado.</td>
                      </tr>
                    ) : (
                      colabs.map((c) => (
                        <tr key={c.idObraColaborador || c.id}>
                          <td>{dash(c.nome)}</td>
                          <td>{dash(c.descricaoCargo)}</td>
                          <td>{dash(c.telefonePrincipal)}</td>
                          <td>{dash(c.email)}</td>
                          <td>{dash(c.descricaoGrupo)}</td>
                          <td>
                            {!visualizar ? (
                              <button type="button" className="btn btn-simple btn-just-icon" title="Editar" disabled>
                                <i className="fa fa-edit" aria-hidden="true" />
                              </button>
                            ) : null}
                          </td>
                          <td>
                            {!visualizar ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Remover"
                                onClick={() =>
                                  setColabs((prev) => prev.filter((x) => x.idObraColaborador !== c.idObraColaborador))
                                }
                              >
                                <i className="fa fa-trash-o" aria-hidden="true" />
                              </button>
                            ) : null}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>

              <div className="col-xs-12 no-padding header-table">
                <h4>EQUIPAMENTOS</h4>
                {!visualizar ? (
                  <div className="pull-right">
                    <button type="button" className="btn btn-blue btn-block-xs" disabled={saving} onClick={() => void onSave()}>
                      <i className="fa fa-save" aria-hidden="true" /> SALVAR TAREFA
                    </button>
                    <button type="button" className="btn btn-blue btn-block-xs" onClick={openEquipModal}>
                      <i className="fa fa-cogs" aria-hidden="true" /> ADICIONAR EQUIPAMENTOS
                    </button>
                    <button
                      type="button"
                      className="btn btn-blue btn-block-xs"
                      onClick={() => showToast('error', 'Cadastro de novo equipamento da obra ainda não está nesta tela. Use Adicionar equipamentos para o que já está na obra.')}
                    >
                      <i className="fa fa-plus" aria-hidden="true" /> NOVO EQUIPAMENTO
                    </button>
                  </div>
                ) : null}
              </div>
              <div className="tabela table-responsive">
                <table className="table table-striped">
                  <thead>
                    <tr>
                      <th>Tipo de Equipamento</th>
                      <th>Descrição</th>
                      <th>Tipo de Aquisição</th>
                      <th>Fabricante/Fornecedor</th>
                      <th>Contato</th>
                      <th>Telefone</th>
                      <th colSpan={2}>AÇÕES</th>
                    </tr>
                  </thead>
                  <tbody>
                    {equips.length === 0 ? (
                      <tr>
                        <td colSpan={8}>Nenhum registro encontrado.</td>
                      </tr>
                    ) : (
                      equips.map((eq) => (
                        <tr key={eq.idObraEquipamento || eq.id}>
                          <td>{dash(eq.tipoEquipamento)}</td>
                          <td>{dash(eq.descricao)}</td>
                          <td>{tipoAquisicaoLabel(eq.tipoAquisicao)}</td>
                          <td>{dash(eq.fabricanteFornecedor)}</td>
                          <td>{dash(eq.contato)}</td>
                          <td>{dash(eq.telefone)}</td>
                          <td>
                            <button type="button" className="btn btn-simple btn-just-icon" title="Visualizar" disabled>
                              <i className="fa fa-eye" aria-hidden="true" />
                            </button>
                          </td>
                          <td>
                            {!visualizar ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Remover"
                                onClick={() =>
                                  setEquips((prev) =>
                                    prev.filter((x) => x.idObraEquipamento !== eq.idObraEquipamento),
                                  )
                                }
                              >
                                <i className="fa fa-trash-o" aria-hidden="true" />
                              </button>
                            ) : null}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>

              {status !== STATUS_PLANEJADA ? (
                <>
                  <div className="col-xs-12 no-padding header-table">
                    <h4>ACIDENTES</h4>
                    {!visualizar ? (
                      <div className="pull-right">
                        <button
                          type="button"
                          className="btn btn-blue btn-block-xs"
                          onClick={() => showToast('error', 'Cadastro de acidente nesta tela entra no próximo recorte. A lista já lê o que existe no banco.')}
                        >
                          <i className="fa fa-plus" aria-hidden="true" /> NOVO ACIDENTE
                        </button>
                      </div>
                    ) : null}
                  </div>
                  <div className="tabela table-responsive">
                    <table className="table table-striped">
                      <thead>
                        <tr>
                          <th>Descrição</th>
                          <th>Data/Hora do Acidente</th>
                          <th>Houve Afastamento</th>
                          <th colSpan={2}>Ações</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.listaAcidentes ?? []).length === 0 ? (
                          <tr>
                            <td colSpan={5}>Nenhum registro encontrado.</td>
                          </tr>
                        ) : (
                          (data.listaAcidentes ?? []).map((a) => (
                            <tr key={a.id}>
                              <td>{dash(a.descricao)}</td>
                              <td>{dash(a.dataHora)}</td>
                              <td>{a.houveAfastamento ? 'Sim' : 'Não'}</td>
                              <td>
                                <button type="button" className="btn btn-simple btn-just-icon" title="Visualizar" disabled>
                                  <i className="fa fa-eye" aria-hidden="true" />
                                </button>
                              </td>
                              <td />
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </>
              ) : null}
            </div>

            {modal === 'historico' ? (
              <div
                className="tarefa-modal-backdrop"
                role="presentation"
                onClick={() => setModal(null)}
              >
                <div
                  className="tarefa-modal"
                  role="dialog"
                  aria-labelledby="historico-medicoes-titulo"
                  onClick={(e) => e.stopPropagation()}
                >
                  <div className="tarefa-modal-header">
                    <h4 id="historico-medicoes-titulo">MEDIÇÕES</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    <h4>{data.descricao}</h4>
                    <div className="tabela table-responsive">
                      <table className="table table-striped">
                        <thead>
                          <tr>
                            <th>Data</th>
                            <th>Hora Inicial</th>
                            <th>Hora Final</th>
                            <th>Status</th>
                            <th>Horímetro Inicial</th>
                            <th>Horímetro Final</th>
                            <th>Horas Trabalhadas</th>
                            <th>Qtd. Contruída</th>
                            <th>Unidade</th>
                            <th>Usuário</th>
                            <th colSpan={2} />
                          </tr>
                        </thead>
                        <tbody>
                          {(data.listaHistoricoTarefa ?? []).length === 0 ? (
                            <tr>
                              <td colSpan={12}>Nenhum registro encontrado.</td>
                            </tr>
                          ) : (
                            (data.listaHistoricoTarefa ?? []).map((h) => (
                              <tr key={h.idTarefa}>
                                <td>{dash(h.data)}</td>
                                <td>{dash(h.horaInicial)}</td>
                                <td>{dash(h.horaFinal)}</td>
                                <td>{dash(h.descricaoStatusTarefa)}</td>
                                <td>{fmtNum(h.horimetroInicial)}</td>
                                <td>{fmtNum(h.horimetroFinal)}</td>
                                <td>{fmtNum(h.horimetroTotal)}</td>
                                <td>{fmtNum(h.qtdConstruida)}</td>
                                <td>{dash(h.unidadeMedida)}</td>
                                <td>{dash(h.nomeColaborador)}</td>
                                <td>
                                  <button
                                    type="button"
                                    className="btn btn-simple btn-just-icon"
                                    title="Visualizar Tarefa"
                                    onClick={() =>
                                      goOperador(`/Tarefa/Cadastro?id=${h.idTarefa}&modo=visualizar`)
                                    }
                                  >
                                    <i className="fa fa-eye" aria-hidden="true" />
                                  </button>
                                </td>
                                <td>
                                  {!h.rdoAssinado && !visualizar ? (
                                    <button
                                      type="button"
                                      className="btn btn-simple btn-just-icon"
                                      title="Editar Tarefa"
                                      onClick={() => goOperador(`/Tarefa/Cadastro?id=${h.idTarefa}`)}
                                    >
                                      <i className="fa fa-edit" aria-hidden="true" />
                                    </button>
                                  ) : null}
                                </td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      × CANCELAR
                    </button>
                  </div>
                </div>
              </div>
            ) : null}

            {modal === 'colab' ? (
              <div className="tarefa-modal-backdrop" role="presentation" onClick={() => setModal(null)}>
                <div className="tarefa-modal" role="dialog" onClick={(e) => e.stopPropagation()}>
                  <div className="tarefa-modal-header">
                    <h4>Adicionar colaborador</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    {(data.colaboradoresObra ?? []).length === 0 ? (
                      <p>Nenhum colaborador cadastrado nesta obra.</p>
                    ) : (
                      <div className="tabela table-responsive">
                        <table className="table table-striped">
                          <thead>
                            <tr>
                              <th />
                              <th>Nome</th>
                              <th>Cargo</th>
                              <th>Perfil</th>
                            </tr>
                          </thead>
                          <tbody>
                            {(data.colaboradoresObra ?? []).map((c) => (
                              <tr key={c.idObraColaborador}>
                                <td>
                                  <input
                                    type="checkbox"
                                    checked={pickedColab.has(c.idObraColaborador)}
                                    onChange={() => {
                                      const next = new Set(pickedColab)
                                      if (next.has(c.idObraColaborador)) next.delete(c.idObraColaborador)
                                      else next.add(c.idObraColaborador)
                                      setPickedColab(next)
                                    }}
                                  />
                                </td>
                                <td>{dash(c.nome)}</td>
                                <td>{dash(c.descricaoCargo)}</td>
                                <td>{dash(c.descricaoGrupo)}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    )}
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      CANCELAR
                    </button>
                    <button type="button" className="btn btn-blue" onClick={confirmColab}>
                      ADICIONAR
                    </button>
                  </div>
                </div>
              </div>
            ) : null}

            {modal === 'equip' ? (
              <div className="tarefa-modal-backdrop" role="presentation" onClick={() => setModal(null)}>
                <div className="tarefa-modal" role="dialog" onClick={(e) => e.stopPropagation()}>
                  <div className="tarefa-modal-header">
                    <h4>Adicionar equipamentos</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    {(data.equipamentosObra ?? []).length === 0 ? (
                      <p>Nenhum equipamento cadastrado nesta obra.</p>
                    ) : (
                      <div className="tabela table-responsive">
                        <table className="table table-striped">
                          <thead>
                            <tr>
                              <th />
                              <th>Tipo</th>
                              <th>Descrição</th>
                            </tr>
                          </thead>
                          <tbody>
                            {(data.equipamentosObra ?? []).map((eq) => (
                              <tr key={eq.idObraEquipamento}>
                                <td>
                                  <input
                                    type="checkbox"
                                    checked={pickedEquip.has(eq.idObraEquipamento)}
                                    onChange={() => {
                                      const next = new Set(pickedEquip)
                                      if (next.has(eq.idObraEquipamento)) next.delete(eq.idObraEquipamento)
                                      else next.add(eq.idObraEquipamento)
                                      setPickedEquip(next)
                                    }}
                                  />
                                </td>
                                <td>{dash(eq.tipoEquipamento)}</td>
                                <td>{dash(eq.descricao)}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    )}
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      CANCELAR
                    </button>
                    <button type="button" className="btn btn-blue" onClick={confirmEquip}>
                      ADICIONAR
                    </button>
                  </div>
                </div>
              </div>
            ) : null}

            <div className="col-md-12 col-xs-12 rdo-cadastro-footer">
              <div className="pull-right">
                <button type="button" className="btn btn-blue btn-block-xs" onClick={() => goOperador(P3_NAV.header.tarefaCards)}>
                  <i className="fa fa-arrow-left" aria-hidden="true" /> VOLTAR
                </button>
                {!visualizar ? (
                  <button type="button" className="btn btn-blue btn-block-xs" disabled={saving} onClick={() => void onSave()}>
                    <i className="fa fa-save" aria-hidden="true" /> SALVAR TAREFA
                  </button>
                ) : null}
              </div>
            </div>
          </>
        ) : null}
      </section>
    </OperadorShell>
  )
}
