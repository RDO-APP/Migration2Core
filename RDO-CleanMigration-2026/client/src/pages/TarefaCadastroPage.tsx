import { useEffect, useMemo, useRef, useState } from 'react'
import { fetchTarefaCadastro, fetchTarefaCadastroNovo, saveTarefaCadastro } from '../api/tarefaApi'
import type {
  TarefaCadastro,
  TarefaCadastroAcidente,
  TarefaCadastroColaborador,
  TarefaCadastroEquipamento,
  TarefaCadastroImagem,
} from '../api/equipamentos-api.types'
import {
  fetchEquipamentoCadastro,
  saveEquipamentoCadastro,
  type EquipamentoCadastroLookup,
} from '../api/equipamentoApi'
import {
  fetchColaboradorCadastro,
  fetchColaboradorIndexMunicipios,
  saveColaboradorCadastro,
  type ColaboradorIndexLookup,
} from '../api/colaboradorApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador, P3_NAV } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import {
  STATUS_PAUSADA,
  STATUS_PLANEJADA,
  buildSaveRequest,
  fileToTarefaImagem,
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
  const etapaId = Number(q.get('etapaId'))
  return {
    id: Number.isFinite(id) && id > 0 ? id : 0,
    etapaId: Number.isFinite(etapaId) && etapaId > 0 ? etapaId : 0,
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
  const [modal, setModal] = useState<null | 'historico' | 'colab' | 'equip' | 'equipNovo' | 'colabNovo' | 'acidente'>(null)
  const [pickedColab, setPickedColab] = useState<Set<number>>(new Set())
  const [pickedEquip, setPickedEquip] = useState<Set<number>>(new Set())
  const [tiposEquip, setTiposEquip] = useState<EquipamentoCadastroLookup[]>([])
  const [novoEquip, setNovoEquip] = useState({
    idTipoEquipamento: 0,
    descricao: '',
    marca: '',
    modelo: '',
    tipoAquisicao: 'S',
    dataAquisicao: '',
    fabricanteFornecedor: '',
    contato: '',
    telefone: '',
  })
  const [savingEquip, setSavingEquip] = useState(false)
  const [acidentes, setAcidentes] = useState<TarefaCadastroAcidente[]>([])
  const [acidentesRemovidos, setAcidentesRemovidos] = useState<number[]>([])
  const [novoAcidente, setNovoAcidente] = useState({ descricao: '', dataHora: '', houveAfastamento: false })
  const [colabLookups, setColabLookups] = useState<{
    grupos: ColaboradorIndexLookup[]
    cargos: ColaboradorIndexLookup[]
    ufs: ColaboradorIndexLookup[]
  }>({ grupos: [], cargos: [], ufs: [] })
  const [municipiosColab, setMunicipiosColab] = useState<ColaboradorIndexLookup[]>([])
  const [savingColab, setSavingColab] = useState(false)
  const [novoColab, setNovoColab] = useState({
    idGrupo: 0,
    nome: '',
    idCargo: 0,
    cpf: '',
    sexo: 'S',
    dataNascimento: '',
    telefonePrincipal: '',
    email: '',
    logradouro: '',
    numeroEndereco: '',
    cep: '',
    idUf: 0,
    idMunicipio: 0,
    senha: '',
    confirmacaoSenha: '',
  })

  const visualizar = flags.visualizar
  const novaMedicao = flags.novaMedicao && !visualizar

  const isNova = flags.id <= 0

  useEffect(() => {
    let cancelled = false
    const load = flags.id > 0 ? fetchTarefaCadastro(flags.id) : fetchTarefaCadastroNovo(flags.etapaId || undefined)
    load
      .then((dto) => {
        if (cancelled) return
        setData(dto)
        setDescricao(dto.descricao)
        setIdEtapa(dto.idEtapa)
        setStatus(dto.status || STATUS_PLANEJADA)
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
        setAcidentes(dto.listaAcidentes ?? [])
        setAcidentesRemovidos([])
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
  }, [flags.id, flags.etapaId, novaMedicao])

  const headerLocked = visualizar || (!isNova && data != null && data.status !== STATUS_PLANEJADA)
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

  async function openNovoEquipModal() {
    try {
      const blank = await fetchEquipamentoCadastro(0)
      setTiposEquip(blank.tipos ?? [])
      setNovoEquip({
        idTipoEquipamento: 0,
        descricao: '',
        marca: '',
        modelo: '',
        tipoAquisicao: 'S',
        dataAquisicao: '',
        fabricanteFornecedor: '',
        contato: '',
        telefone: '',
      })
      setModal('equipNovo')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao abrir cadastro de equipamento.')
    }
  }

  async function saveNovoEquipamento() {
    if (novoEquip.idTipoEquipamento <= 0) {
      showToast('error', 'O Tipo de equipamento deve ser preenchido.')
      return
    }
    if (novoEquip.descricao.trim().length < 2) {
      showToast('error', 'A Descrição deve ser preenchida.')
      return
    }
    setSavingEquip(true)
    try {
      const tipoNome = tiposEquip.find((t) => t.id === novoEquip.idTipoEquipamento)?.nome ?? ''
      const result = await saveEquipamentoCadastro({
        idEquipamento: 0,
        idTipoEquipamento: novoEquip.idTipoEquipamento,
        tipoEquipamento: tipoNome,
        descricao: novoEquip.descricao,
        marca: novoEquip.marca,
        modelo: novoEquip.modelo,
        tipoAquisicao: novoEquip.tipoAquisicao,
        dataAquisicao: novoEquip.dataAquisicao,
        fabricanteFornecedor: novoEquip.fabricanteFornecedor,
        contato: novoEquip.contato,
        telefone: novoEquip.telefone,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar o equipamento.')
        return
      }
      const row: TarefaCadastroEquipamento = {
        id: result.idEquipamento ?? 0,
        idObraEquipamento: result.idObraEquipamento ?? 0,
        tipoEquipamento: tipoNome,
        descricao: novoEquip.descricao.trim(),
        tipoAquisicao: novoEquip.tipoAquisicao,
        fabricanteFornecedor: novoEquip.fabricanteFornecedor,
        contato: novoEquip.contato,
        telefone: novoEquip.telefone,
      }
      setEquips((prev) => [...prev, row])
      setData((prev) =>
        prev
          ? {
              ...prev,
              equipamentosObra: [...(prev.equipamentosObra ?? []), row],
            }
          : prev,
      )
      showToast('success', 'Equipamento criado e adicionado à tarefa.')
      setModal(null)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar o equipamento.')
    } finally {
      setSavingEquip(false)
    }
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

  function togglePickAllColab() {
    const pool = data?.colaboradoresObra ?? []
    if (pool.length === 0) return
    if (pickedColab.size === pool.length) setPickedColab(new Set())
    else setPickedColab(new Set(pool.map((c) => c.idObraColaborador)))
  }

  function togglePickAllEquip() {
    const pool = data?.equipamentosObra ?? []
    if (pool.length === 0) return
    if (pickedEquip.size === pool.length) setPickedEquip(new Set())
    else setPickedEquip(new Set(pool.map((e) => e.idObraEquipamento)))
  }

  /** Paridade prod `verificaPerfilColaborador`: nome exato Colaborador | Terceirizado. */
  function isPerfilLeve(idGrupo: number) {
    const n = (colabLookups.grupos.find((g) => g.id === idGrupo)?.nome ?? '').trim().toLowerCase()
    return n === 'colaborador' || n === 'terceirizado'
  }

  function ReqAsterisk({ show }: { show: boolean }) {
    return show ? <span style={{ color: 'red' }}>*</span> : null
  }

  async function openNovoColabModal() {
    try {
      const blank = await fetchColaboradorCadastro(0)
      setColabLookups({ grupos: blank.grupos ?? [], cargos: blank.cargos ?? [], ufs: blank.ufs ?? [] })
      setMunicipiosColab([])
      setNovoColab({
        idGrupo: 0,
        nome: '',
        idCargo: 0,
        cpf: '',
        sexo: 'S',
        dataNascimento: '',
        telefonePrincipal: '',
        email: '',
        logradouro: '',
        numeroEndereco: '',
        cep: '',
        idUf: 0,
        idMunicipio: 0,
        senha: '',
        confirmacaoSenha: '',
      })
      setModal('colabNovo')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao abrir cadastro de colaborador.')
    }
  }

  async function onNovoColabUf(idUf: number) {
    setNovoColab((prev) => ({ ...prev, idUf, idMunicipio: 0 }))
    if (idUf <= 0) {
      setMunicipiosColab([])
      return
    }
    try {
      setMunicipiosColab(await fetchColaboradorIndexMunicipios(idUf))
    } catch {
      setMunicipiosColab([])
    }
  }

  async function saveNovoColaborador() {
    // Validação = prod TarefaController.adicionarColaborador (CEP/Número opcionais no modal).
    const leve = isPerfilLeve(novoColab.idGrupo)
    if (novoColab.idGrupo <= 0) {
      showToast('error', 'O Perfil deve ser preenchido.')
      return
    }
    if (novoColab.nome.trim().length < 3) {
      showToast('error', 'Por favor, introduza pelo menos três caracteres no Nome.')
      return
    }
    if (novoColab.idCargo <= 0) {
      showToast('error', 'O Cargo deve ser preenchido.')
      return
    }
    if (!leve) {
      if (novoColab.cpf.replace(/\D/g, '').length !== 11) {
        showToast('error', 'O CPF deve ser preenchido.')
        return
      }
      if (novoColab.sexo !== 'M' && novoColab.sexo !== 'F') {
        showToast('error', 'O Sexo deve ser preenchido.')
        return
      }
      if (novoColab.dataNascimento.replace(/\D/g, '').length !== 8) {
        showToast('error', 'A Data de Nascimento deve ser preenchida.')
        return
      }
      if (novoColab.telefonePrincipal.replace(/\D/g, '').length < 10) {
        showToast('error', 'O Telefone Principal deve ser preenchido.')
        return
      }
      if (!novoColab.email.trim()) {
        showToast('error', 'O E-mail deve ser preenchido.')
        return
      }
      if (!novoColab.logradouro.trim()) {
        showToast('error', 'O Logradouro deve ser preenchido.')
        return
      }
      if (novoColab.idUf <= 0) {
        showToast('error', 'A UF deve ser preenchida.')
        return
      }
      if (novoColab.idMunicipio <= 0) {
        showToast('error', 'O Município deve ser preenchido.')
        return
      }
      if (novoColab.senha.length < 4) {
        showToast('error', 'Por favor, introduza pelo menos quatro caracteres na Senha.')
        return
      }
      if (!novoColab.confirmacaoSenha) {
        showToast('error', 'A Confirmação Senha deve ser preenchida.')
        return
      }
      if (novoColab.senha !== novoColab.confirmacaoSenha) {
        showToast('error', 'As senhas digitadas devem ser idênticas.')
        return
      }
    }
    setSavingColab(true)
    try {
      const result = await saveColaboradorCadastro({
        idColaborador: 0,
        cpf: novoColab.cpf,
        idGrupo: novoColab.idGrupo,
        nome: novoColab.nome,
        idCargo: novoColab.idCargo,
        sexo: novoColab.sexo,
        dataNascimento: novoColab.dataNascimento,
        telefonePrincipal: novoColab.telefonePrincipal,
        telefoneSecundario: '',
        email: novoColab.email,
        crea: '',
        dataContratacao: '',
        logradouro: novoColab.logradouro,
        numeroEndereco: novoColab.numeroEndereco,
        complemento: '',
        bairro: '',
        idMunicipio: novoColab.idMunicipio,
        cep: novoColab.cep,
        senha: novoColab.senha,
        confirmacaoSenha: novoColab.confirmacaoSenha,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar o colaborador.')
        return
      }
      const grupoNome = colabLookups.grupos.find((g) => g.id === novoColab.idGrupo)?.nome ?? ''
      const cargoNome = colabLookups.cargos.find((c) => c.id === novoColab.idCargo)?.nome ?? ''
      const row: TarefaCadastroColaborador = {
        id: result.idColaborador ?? 0,
        idObraColaborador: result.idObraColaborador ?? 0,
        nome: novoColab.nome.trim(),
        descricaoCargo: cargoNome,
        telefonePrincipal: novoColab.telefonePrincipal,
        email: novoColab.email,
        descricaoGrupo: grupoNome,
      }
      setColabs((prev) => [...prev, row])
      setData((prev) =>
        prev ? { ...prev, colaboradoresObra: [...(prev.colaboradoresObra ?? []), row] } : prev,
      )
      showToast('success', 'Colaborador criado e adicionado à tarefa.')
      setModal(null)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar o colaborador.')
    } finally {
      setSavingColab(false)
    }
  }

  function openNovoAcidenteModal() {
    setNovoAcidente({ descricao: '', dataHora: '', houveAfastamento: false })
    setModal('acidente')
  }

  function saveNovoAcidenteLocal() {
    if (novoAcidente.descricao.trim().length < 3) {
      showToast('error', 'A Descrição do Acidente deve ser preenchida')
      return
    }
    if (novoAcidente.dataHora.replace(/\D/g, '').length < 8) {
      showToast('error', 'A Data/Hora do Acidente deve ser preenchida.')
      return
    }
    setAcidentes((prev) => [
      ...prev,
      {
        id: -Date.now(),
        descricao: novoAcidente.descricao.trim(),
        dataHora: novoAcidente.dataHora.trim(),
        houveAfastamento: novoAcidente.houveAfastamento,
      },
    ])
    setModal(null)
  }

  function removeAcidente(id: number) {
    setAcidentes((prev) => prev.filter((a) => a.id !== id))
    if (id > 0) setAcidentesRemovidos((prev) => [...prev, id])
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

  async function onAdicionarFoto() {
    const file = fileRef.current?.files?.[0]
    if (!file) {
      showToast('error', 'Selecione um arquivo.')
      return
    }
    if (file.size > 2 * 1024 * 1024) {
      showToast('error', 'O tamanho máximo da imagem é de 2MB.')
      return
    }
    try {
      const img = await fileToTarefaImagem(file)
      setFotos((prev) => [...prev, img])
      setFotoNome('')
      if (fileRef.current) fileRef.current.value = ''
    } catch {
      showToast('error', 'Falha ao ler a foto.')
    }
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
            listaAcidentes: acidentes,
            listaIdsAcidentesRemovidos: acidentesRemovidos,
            listaImagens: fotos,
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

  const title = visualizar
    ? 'Visualizar tarefa'
    : novaMedicao
      ? 'Nova medição'
      : isNova
        ? 'Nova tarefa'
        : 'Tarefa / Medição'

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
                    <button type="button" className="btn btn-blue btn-block-xs" onClick={() => void openNovoColabModal()}>
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
                    <button type="button" className="btn btn-blue btn-block-xs" onClick={() => void openNovoEquipModal()}>
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
                        <button type="button" className="btn btn-blue btn-block-xs" onClick={openNovoAcidenteModal}>
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
                        {acidentes.length === 0 ? (
                          <tr>
                            <td colSpan={5}>Nenhum registro encontrado.</td>
                          </tr>
                        ) : (
                          acidentes.map((a) => (
                            <tr key={a.id}>
                              <td>{dash(a.descricao)}</td>
                              <td>{dash(a.dataHora)}</td>
                              <td>{a.houveAfastamento ? 'Sim' : 'Não'}</td>
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
                                    onClick={() => removeAcidente(a.id)}
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
                              <th>
                                <input
                                  type="checkbox"
                                  checked={
                                    (data.colaboradoresObra ?? []).length > 0 &&
                                    pickedColab.size === (data.colaboradoresObra ?? []).length
                                  }
                                  onChange={togglePickAllColab}
                                  title="Marcar todos"
                                />
                              </th>
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
                              <th>
                                <input
                                  type="checkbox"
                                  checked={
                                    (data.equipamentosObra ?? []).length > 0 &&
                                    pickedEquip.size === (data.equipamentosObra ?? []).length
                                  }
                                  onChange={togglePickAllEquip}
                                  title="Marcar todos"
                                />
                              </th>
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

            {modal === 'equipNovo' ? (
              <div className="tarefa-modal-backdrop" role="presentation" onClick={() => setModal(null)}>
                <div className="tarefa-modal" role="dialog" onClick={(e) => e.stopPropagation()}>
                  <div className="tarefa-modal-header">
                    <h4>Equipamento</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    <div className="form-group">
                      <label className="control-label">
                        Tipo de Equipamento<span style={{ color: 'red' }}>*</span>
                      </label>
                      <select
                        className="form-control"
                        value={novoEquip.idTipoEquipamento}
                        onChange={(e) =>
                          setNovoEquip({ ...novoEquip, idTipoEquipamento: Number(e.target.value) || 0 })
                        }
                      >
                        <option value={0}>Selecione...</option>
                        {tiposEquip.map((t) => (
                          <option key={t.id} value={t.id}>
                            {t.nome}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="form-group">
                      <label className="control-label">
                        Descrição<span style={{ color: 'red' }}>*</span>
                      </label>
                      <input
                        className="form-control"
                        maxLength={50}
                        value={novoEquip.descricao}
                        onChange={(e) => setNovoEquip({ ...novoEquip, descricao: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Marca</label>
                      <input
                        className="form-control"
                        maxLength={50}
                        value={novoEquip.marca}
                        onChange={(e) => setNovoEquip({ ...novoEquip, marca: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Modelo</label>
                      <input
                        className="form-control"
                        maxLength={50}
                        value={novoEquip.modelo}
                        onChange={(e) => setNovoEquip({ ...novoEquip, modelo: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Tipo de Aquisição</label>
                      <select
                        className="form-control"
                        value={novoEquip.tipoAquisicao}
                        onChange={(e) => setNovoEquip({ ...novoEquip, tipoAquisicao: e.target.value })}
                      >
                        <option value="S">Selecione...</option>
                        <option value="A">Aluguel</option>
                        <option value="C">Compra</option>
                      </select>
                    </div>
                    <div className="form-group">
                      <label className="control-label">Data da Aquisição</label>
                      <input
                        className="form-control"
                        maxLength={10}
                        placeholder="dd/mm/aaaa"
                        value={novoEquip.dataAquisicao}
                        onChange={(e) => setNovoEquip({ ...novoEquip, dataAquisicao: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Fornecedor/Fabricante</label>
                      <input
                        className="form-control"
                        maxLength={50}
                        value={novoEquip.fabricanteFornecedor}
                        onChange={(e) => setNovoEquip({ ...novoEquip, fabricanteFornecedor: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Contato</label>
                      <input
                        className="form-control"
                        maxLength={50}
                        value={novoEquip.contato}
                        onChange={(e) => setNovoEquip({ ...novoEquip, contato: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Telefone</label>
                      <input
                        className="form-control"
                        maxLength={15}
                        value={novoEquip.telefone}
                        onChange={(e) => setNovoEquip({ ...novoEquip, telefone: e.target.value })}
                      />
                    </div>
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      CANCELAR
                    </button>
                    <button
                      type="button"
                      className="btn btn-blue"
                      disabled={savingEquip}
                      onClick={() => void saveNovoEquipamento()}
                    >
                      SALVAR
                    </button>
                  </div>
                </div>
              </div>
            ) : null}


            {modal === 'colabNovo' ? (
              <div className="tarefa-modal-backdrop" role="presentation" onClick={() => setModal(null)}>
                <div className="tarefa-modal" role="dialog" onClick={(e) => e.stopPropagation()}>
                  <div className="tarefa-modal-header">
                    <h4>COLABORADOR</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    {(() => {
                      const leve = isPerfilLeve(novoColab.idGrupo)
                      const reqFull = !leve
                      return (
                        <>
                          <div className="form-group">
                            <label className="control-label">Perfil do Colaborador<ReqAsterisk show /></label>
                            <select
                              className="form-control"
                              value={novoColab.idGrupo}
                              onChange={(e) => setNovoColab({ ...novoColab, idGrupo: Number(e.target.value) || 0 })}
                            >
                              <option value={0}>Selecione...</option>
                              {colabLookups.grupos.map((g) => (
                                <option key={g.id} value={g.id}>{g.nome}</option>
                              ))}
                            </select>
                          </div>
                          <div className="form-group">
                            <label className="control-label">CPF<ReqAsterisk show={reqFull} /></label>
                            <input className="form-control" value={novoColab.cpf} onChange={(e) => setNovoColab({ ...novoColab, cpf: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">Nome<ReqAsterisk show /></label>
                            <input className="form-control" maxLength={50} value={novoColab.nome} onChange={(e) => setNovoColab({ ...novoColab, nome: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">Cargo<ReqAsterisk show /></label>
                            <select className="form-control" value={novoColab.idCargo} onChange={(e) => setNovoColab({ ...novoColab, idCargo: Number(e.target.value) || 0 })}>
                              <option value={0}>Selecione...</option>
                              {colabLookups.cargos.map((c) => (
                                <option key={c.id} value={c.id}>{c.nome}</option>
                              ))}
                            </select>
                          </div>
                          <div className="form-group">
                            <label className="control-label">Sexo<ReqAsterisk show={reqFull} /></label>
                            <select className="form-control" value={novoColab.sexo} onChange={(e) => setNovoColab({ ...novoColab, sexo: e.target.value })}>
                              <option value="S">Selecione...</option>
                              <option value="M">Masculino</option>
                              <option value="F">Feminino</option>
                            </select>
                          </div>
                          <div className="form-group">
                            <label className="control-label">Data de Nascimento<ReqAsterisk show={reqFull} /></label>
                            <input className="form-control" placeholder="dd/mm/aaaa" value={novoColab.dataNascimento} onChange={(e) => setNovoColab({ ...novoColab, dataNascimento: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">Telefone Principal<ReqAsterisk show={reqFull} /></label>
                            <input className="form-control" value={novoColab.telefonePrincipal} onChange={(e) => setNovoColab({ ...novoColab, telefonePrincipal: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">E-mail<ReqAsterisk show={reqFull} /></label>
                            <input className="form-control" value={novoColab.email} onChange={(e) => setNovoColab({ ...novoColab, email: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">Logradouro<ReqAsterisk show={reqFull} /></label>
                            <input className="form-control" value={novoColab.logradouro} onChange={(e) => setNovoColab({ ...novoColab, logradouro: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">Número</label>
                            <input className="form-control" maxLength={5} value={novoColab.numeroEndereco} onChange={(e) => setNovoColab({ ...novoColab, numeroEndereco: e.target.value })} />
                          </div>
                          <div className="form-group">
                            <label className="control-label">UF<ReqAsterisk show={reqFull} /></label>
                            <select className="form-control" value={novoColab.idUf} onChange={(e) => void onNovoColabUf(Number(e.target.value) || 0)}>
                              <option value={0}>Selecione...</option>
                              {colabLookups.ufs.map((u) => (
                                <option key={u.id} value={u.id}>{u.nome}</option>
                              ))}
                            </select>
                          </div>
                          <div className="form-group">
                            <label className="control-label">Município<ReqAsterisk show={reqFull} /></label>
                            <select className="form-control" value={novoColab.idMunicipio} onChange={(e) => setNovoColab({ ...novoColab, idMunicipio: Number(e.target.value) || 0 })}>
                              <option value={0}>Selecione...</option>
                              {municipiosColab.map((m) => (
                                <option key={m.id} value={m.id}>{m.nome}</option>
                              ))}
                            </select>
                          </div>
                          <div className="form-group">
                            <label className="control-label">CEP</label>
                            <input className="form-control" value={novoColab.cep} onChange={(e) => setNovoColab({ ...novoColab, cep: e.target.value })} />
                          </div>
                          {!leve ? (
                            <>
                              <div className="form-group">
                                <label className="control-label">Senha<ReqAsterisk show /></label>
                                <input type="password" className="form-control" maxLength={20} value={novoColab.senha} onChange={(e) => setNovoColab({ ...novoColab, senha: e.target.value })} />
                              </div>
                              <div className="form-group">
                                <label className="control-label">Confirmação Senha<ReqAsterisk show /></label>
                                <input type="password" className="form-control" maxLength={20} value={novoColab.confirmacaoSenha} onChange={(e) => setNovoColab({ ...novoColab, confirmacaoSenha: e.target.value })} />
                              </div>
                            </>
                          ) : null}
                        </>
                      )
                    })()}
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>CANCELAR</button>
                    <button type="button" className="btn btn-blue" disabled={savingColab} onClick={() => void saveNovoColaborador()}>SALVAR</button>
                  </div>
                </div>
              </div>
            ) : null}

            {modal === 'acidente' ? (
              <div className="tarefa-modal-backdrop" role="presentation" onClick={() => setModal(null)}>
                <div className="tarefa-modal" role="dialog" onClick={(e) => e.stopPropagation()}>
                  <div className="tarefa-modal-header">
                    <h4>Acidente</h4>
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>
                      <i className="icon-close" aria-hidden="true" />
                    </button>
                  </div>
                  <div className="tarefa-modal-body">
                    <div className="form-group">
                      <label className="control-label">Descrição<span style={{ color: 'red' }}>*</span></label>
                      <textarea className="form-control" rows={3} value={novoAcidente.descricao} onChange={(e) => setNovoAcidente({ ...novoAcidente, descricao: e.target.value })} />
                    </div>
                    <div className="form-group">
                      <label className="control-label">Data/Hora<span style={{ color: 'red' }}>*</span></label>
                      <input className="form-control" placeholder="dd/mm/aaaa HH:mm" value={novoAcidente.dataHora} onChange={(e) => setNovoAcidente({ ...novoAcidente, dataHora: e.target.value })} />
                    </div>
                    <div className="form-group">
                      <label>
                        <input type="checkbox" checked={novoAcidente.houveAfastamento} onChange={(e) => setNovoAcidente({ ...novoAcidente, houveAfastamento: e.target.checked })} />{' '}
                        Houve afastamento
                      </label>
                    </div>
                  </div>
                  <div className="tarefa-modal-footer">
                    <button type="button" className="btn btn-simple" onClick={() => setModal(null)}>CANCELAR</button>
                    <button type="button" className="btn btn-blue" onClick={saveNovoAcidenteLocal}>ADICIONAR</button>
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
