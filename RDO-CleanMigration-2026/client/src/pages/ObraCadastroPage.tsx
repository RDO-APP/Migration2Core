import { useEffect, useRef, useState } from 'react'
import {
  fetchObraCadastro,
  fetchViaCep,
  saveObraCadastro,
  type ObraCadastro,
  type ObraCadastroLookup,
} from '../api/obraCadastroApi'
import {
  deleteColaboradorIndex,
  fetchColaboradorIndexLista,
  type ColaboradorIndexItem,
} from '../api/colaboradorApi'
import {
  deleteEquipamentoIndex,
  fetchEquipamentoIndexLista,
  type EquipamentoIndexItem,
} from '../api/equipamentoApi'
import { fetchObraIndexBootstrap, fetchObraIndexMunicipios, type ObraIndexLookup } from '../api/obrasApi'
import { OperadorShell } from '../components/OperadorShell'
import { useShellContext } from '../hooks/useShellContext'
import { goOperador } from '../nav/p3-operador-routes'
import { flashToast, showToast } from '../toast'
import '../rdo-cadastro.css'
import '../tarefa-cadastro.css'

function labelTipoAquisicao(tp?: string) {
  if (tp === 'C') return 'Compra'
  if (tp === 'A') return 'Aluguel'
  return '—'
}

const MAX_LOGO_BYTES = 2 * 1024 * 1024

type FormState = {
  descricao: string
  idContratante: number
  idContratada: number
  dataInicio: string
  dataPrevisaoFim: string
  cep: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  idUf: number
  idMunicipio: number
  finalizada: boolean
}

function toForm(d: ObraCadastro): FormState {
  return {
    descricao: d.descricao ?? '',
    idContratante: d.idContratante ?? 0,
    idContratada: d.idContratada ?? 0,
    dataInicio: d.dataInicio ?? '',
    dataPrevisaoFim: d.dataPrevisaoFim ?? '',
    cep: d.cep ?? '',
    logradouro: d.logradouro ?? '',
    numero: d.numero ?? '',
    complemento: d.complemento ?? '',
    bairro: d.bairro ?? '',
    idUf: d.idUf ?? 0,
    idMunicipio: d.idMunicipio ?? 0,
    finalizada: d.finalizada,
  }
}

function copiarIdFromUrl(): number {
  const raw = new URLSearchParams(window.location.search).get('copiar')
  const n = raw ? Number(raw) : 0
  return Number.isFinite(n) && n > 0 ? n : 0
}

function modoFromUrl(): 'nova' | 'editar' | 'visualizar' {
  const q = new URLSearchParams(window.location.search)
  if (copiarIdFromUrl() > 0) return 'nova'
  if (q.get('nova') === '1' || q.get('nova')?.toLowerCase() === 'true') return 'nova'
  const m = q.get('modo')?.toLowerCase()
  return m === 'visualizar' ? 'visualizar' : 'editar'
}

function digitsOnly(v: string, max: number) {
  return v.replace(/\D/g, '').slice(0, max)
}

function matchMunicipio(list: ObraIndexLookup[], localidade: string): number {
  const target = localidade.trim().toLowerCase()
  if (!target) return 0
  const exact = list.find((m) => m.nome.trim().toLowerCase() === target)
  if (exact) return exact.id
  const partial = list.find(
    (m) =>
      m.nome.trim().toLowerCase().includes(target) || target.includes(m.nome.trim().toLowerCase()),
  )
  return partial?.id ?? 0
}

function readFileAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result ?? ''))
    reader.onerror = () => reject(new Error('Falha ao ler arquivo.'))
    reader.readAsDataURL(file)
  })
}

export function ObraCadastroPage() {
  const { shell } = useShellContext()
  const modo = modoFromUrl()
  const copiarId = copiarIdFromUrl()
  const isNova = modo === 'nova'
  const isCopia = copiarId > 0
  const fileRef = useRef<HTMLInputElement>(null)
  const [form, setForm] = useState<FormState | null>(null)
  const [empresas, setEmpresas] = useState<ObraCadastroLookup[]>([])
  const [ufs, setUfs] = useState<ObraIndexLookup[]>([])
  const [municipios, setMunicipios] = useState<ObraIndexLookup[]>([])
  const [fotoPreview, setFotoPreview] = useState('')
  const [fotoPayload, setFotoPayload] = useState<string | null>(null)
  const [removerFoto, setRemoverFoto] = useState(false)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [cepBusy, setCepBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [colaboradores, setColaboradores] = useState<ColaboradorIndexItem[]>([])
  const [equipamentos, setEquipamentos] = useState<EquipamentoIndexItem[]>([])
  const [listBusy, setListBusy] = useState(false)

  async function reloadVinculos() {
    if (isNova) {
      setColaboradores([])
      setEquipamentos([])
      return
    }
    setListBusy(true)
    try {
      const emptyColab = {
        nome: '',
        cpf: '',
        sexo: 'S',
        email: '',
        crea: '',
        idUf: 0,
        idMunicipio: 0,
        idCargo: 0,
        idGrupo: 0,
        dataContratacao: '',
      }
      const emptyEquip = {
        tipoEquipamento: '',
        descricao: '',
        marca: '',
        modelo: '',
        tipoAquisicao: 'S',
        fabricanteFornecedor: '',
      }
      const [cols, eqs] = await Promise.all([
        fetchColaboradorIndexLista(emptyColab),
        fetchEquipamentoIndexLista(emptyEquip),
      ])
      setColaboradores(cols.items ?? [])
      setEquipamentos(eqs.items ?? [])
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao carregar vínculos da obra.')
    } finally {
      setListBusy(false)
    }
  }

  useEffect(() => {
    let cancelled = false
    const loadOpts = isCopia ? { copiar: copiarId } : { nova: isNova }
    Promise.all([fetchObraCadastro(loadOpts), fetchObraIndexBootstrap()])
      .then(async ([d, boot]) => {
        if (cancelled) return
        setUfs(boot.ufs)
        setEmpresas(d.empresas ?? [])
        const next = toForm(d)
        setForm(next)
        const existing = (d.descricaoFoto ?? '').trim()
        setFotoPreview(existing)
        setFotoPayload(existing || null)
        setRemoverFoto(false)
        if (next.idUf > 0) {
          const muns = await fetchObraIndexMunicipios(next.idUf)
          if (!cancelled) setMunicipios(muns)
        }
        if (!isNova) {
          await reloadVinculos()
        } else {
          setColaboradores([])
          setEquipamentos([])
        }
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar obra.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isNova, isCopia, copiarId])

  function setField<K extends keyof FormState>(key: K, value: FormState[K]) {
    setForm((prev) => (prev ? { ...prev, [key]: value } : prev))
  }

  async function onUfChange(idUf: number) {
    setForm((prev) => (prev ? { ...prev, idUf, idMunicipio: 0 } : prev))
    if (idUf <= 0) {
      setMunicipios([])
      return
    }
    try {
      setMunicipios(await fetchObraIndexMunicipios(idUf))
    } catch {
      setMunicipios([])
      showToast('error', 'Não foi possível carregar municípios.')
    }
  }

  const disabled = (!isNova && !!form?.finalizada) || modo === 'visualizar'
  const lastCepLookup = useRef('')

  async function lookupCep(raw: string) {
    if (disabled) return
    const cep = digitsOnly(raw, 8)
    if (cep.length !== 8) return
    if (cep === lastCepLookup.current && !cepBusy) return
    lastCepLookup.current = cep
    setCepBusy(true)
    try {
      const via = await fetchViaCep(cep)
      if (!via) {
        showToast('error', 'CEP não encontrado.')
        return
      }
      const ufSigla = (via.uf ?? '').trim().toUpperCase()
      const uf = ufs.find((u) => u.nome.trim().toUpperCase() === ufSigla)
      let idUf = 0
      let idMunicipio = 0
      if (uf) {
        idUf = uf.id
        const muns = await fetchObraIndexMunicipios(idUf)
        setMunicipios(muns)
        idMunicipio = matchMunicipio(muns, via.localidade ?? '')
      } else {
        showToast('error', `UF ${ufSigla || '?'} não encontrada na lista.`)
      }
      setForm((prev) =>
        prev
          ? {
              ...prev,
              cep,
              logradouro: via.logradouro?.trim() || prev.logradouro,
              bairro: via.bairro?.trim() || prev.bairro,
              idUf: idUf || prev.idUf,
              idMunicipio: idMunicipio || (idUf ? 0 : prev.idMunicipio),
            }
          : prev,
      )
    } catch {
      lastCepLookup.current = ''
      showToast('error', 'Falha ao consultar o CEP.')
    } finally {
      setCepBusy(false)
    }
  }

  async function onLogoSelected(file: File | null) {
    if (!file || disabled) return
    if (file.size > MAX_LOGO_BYTES) {
      showToast('error', 'Tamanho máximo do logo: 2MB.')
      return
    }
    try {
      const dataUrl = await readFileAsDataUrl(file)
      const head = dataUrl.slice(0, 40).toLowerCase()
      if (!head.includes('jpeg') && !head.includes('jpg') && !head.includes('png') && !head.includes('bmp')) {
        showToast('error', 'Formato inválido. Use jpeg, jpg, bmp ou png.')
        return
      }
      setFotoPreview(dataUrl)
      setFotoPayload(dataUrl)
      setRemoverFoto(false)
    } catch {
      showToast('error', 'Falha ao ler a imagem.')
    }
  }

  function onRemoverLogo() {
    if (disabled) return
    setFotoPreview('')
    setFotoPayload(null)
    setRemoverFoto(true)
    if (fileRef.current) fileRef.current.value = ''
  }

  async function onSave() {
    if (!form) return
    if (!isNova && form.finalizada) {
      showToast('error', 'Obra finalizada — edição bloqueada.')
      return
    }
    const descricao = form.descricao.trim()
    if (descricao.length < 3) {
      showToast('error', 'Informe o nome da obra (mín. 3 caracteres).')
      return
    }
    if (form.idContratante <= 0 && form.idContratada <= 0) {
      showToast('error', 'Informe Contratante e/ou Contratada (pelo menos um).')
      return
    }
    if (form.idContratante > 0 && form.idContratante === form.idContratada) {
      showToast('error', 'Contratante e Contratada não podem ser a mesma empresa.')
      return
    }
    if (!form.dataInicio.trim()) {
      showToast('error', 'A Data inicial deve ser preenchida.')
      return
    }
    if (digitsOnly(form.cep, 8).length !== 8) {
      showToast('error', 'Informe um CEP válido (8 dígitos).')
      return
    }
    if (form.idMunicipio <= 0) {
      showToast('error', 'Informe UF e Município (obrigatórios).')
      return
    }
    setSaving(true)
    try {
      const result = await saveObraCadastro({
        nova: isNova,
        descricao,
        dataInicio: form.dataInicio.trim(),
        dataPrevisaoFim: form.dataPrevisaoFim.trim(),
        logradouro: form.logradouro.trim(),
        numero: form.numero.trim(),
        complemento: form.complemento.trim(),
        bairro: form.bairro.trim(),
        cep: form.cep.trim(),
        idMunicipio: form.idMunicipio,
        idContratante: form.idContratante,
        idContratada: form.idContratada,
        areaTotal: null,
        areaConstruida: null,
        foto: removerFoto ? null : fotoPayload,
        removerFoto,
      })
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      flashToast(
        'success',
        isNova
          ? 'Obra criada. Agora você pode adicionar colaboradores e equipamentos.'
          : 'Registro salvo com sucesso.',
      )
      // Após criar, fica no cadastro (edição) para Blocos 3/4.
      goOperador('/Obra/Cadastro')
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  const temEmpresa = (form?.idContratante ?? 0) > 0 || (form?.idContratada ?? 0) > 0
  const canManageVinculos = !isNova && !disabled && temEmpresa

  function openColaborador(modo: 'novo' | 'editar', id?: number) {
    if (!canManageVinculos && modo === 'novo') {
      if (isNova) showToast('error', 'Salve a obra antes de adicionar colaboradores.')
      else if (!temEmpresa) showToast('error', 'Informe Contratante ou Contratada.')
      return
    }
    const q = new URLSearchParams()
    if (modo === 'novo') q.set('modo', 'novo')
    else if (id) q.set('id', String(id))
    goOperador(`/colaborador/cadastro${q.toString() ? `?${q}` : ''}`)
  }

  function openEquipamento(modo: 'novo' | 'editar', id?: number) {
    if (!canManageVinculos && modo === 'novo') {
      if (isNova) showToast('error', 'Salve a obra antes de adicionar equipamentos.')
      else if (!temEmpresa) showToast('error', 'Informe Contratante ou Contratada.')
      return
    }
    const q = new URLSearchParams()
    if (modo === 'novo') q.set('modo', 'novo')
    else if (id) q.set('id', String(id))
    goOperador(`/equipamentos/cadastro${q.toString() ? `?${q}` : ''}`)
  }

  async function onRemoveColaborador(col: ColaboradorIndexItem) {
    if (!col.excluivel || disabled) return
    if (!window.confirm(`Remover ${col.nome} desta obra?`)) return
    try {
      const r = await deleteColaboradorIndex(col.idColaborador)
      if (!r.ok) {
        showToast('error', r.errorMessage || 'Não foi possível remover.')
        return
      }
      flashToast('success', 'Colaborador removido.')
      await reloadVinculos()
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao remover colaborador.')
    }
  }

  async function onRemoveEquipamento(eq: EquipamentoIndexItem) {
    if (disabled) return
    if (!window.confirm(`Remover equipamento "${eq.descricao}" desta obra?`)) return
    try {
      const r = await deleteEquipamentoIndex(eq.idEquipamento)
      if (!r.ok) {
        showToast('error', r.errorMessage || 'Não foi possível remover.')
        return
      }
      flashToast('success', 'Equipamento removido.')
      await reloadVinculos()
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao remover equipamento.')
    }
  }

  return (
    <OperadorShell variant="cards" obraNome={form?.descricao || shell?.obraNome} shell={shell}>
      <section className="rdo-cadastro-page tarefa-cadastro-page">
        <div className="panel-heading">
          <h3>{isCopia ? 'Copiar obra' : isNova ? 'Nova obra' : 'Obra'}</h3>
        </div>
        {loading ? (
          <p className="muted">Carregando…</p>
        ) : error ? (
          <p className="error">{error}</p>
        ) : form ? (
          <>
            {isCopia ? (
              <p className="muted">
                Cabeçalho pré-preenchido da obra origem. Ao salvar, cria obra nova (colaboradores e
                equipamentos adicionar depois).
              </p>
            ) : modo === 'visualizar' ? (
              <p className="muted">Modo visualizar — campos somente leitura.</p>
            ) : form.finalizada ? (
              <p className="muted">Obra finalizada — campos somente leitura.</p>
            ) : null}
            <form
              className="panel"
              onSubmit={(e) => {
                e.preventDefault()
                void onSave()
              }}
            >
              <div className="row g-3">
                <div className="col-md-8">
                  <div className="row g-3">
                    <div className="col-12">
                      <div className="form-group">
                        <label className="control-label">
                          Nome da Obra<span style={{ color: 'red' }}>*</span>
                        </label>
                        <input
                          type="text"
                          className="form-control"
                          maxLength={50}
                          disabled={disabled}
                          value={form.descricao}
                          onChange={(e) => setField('descricao', e.target.value)}
                        />
                      </div>
                    </div>
                    <div className="col-md-6">
                      <div className="form-group">
                        <label className="control-label">Contratante</label>
                        <select
                          className="form-control"
                          disabled={disabled}
                          value={form.idContratante || 0}
                          onChange={(e) => {
                            const id = Number(e.target.value) || 0
                            // Opção A: um lado por vez — escolher Contratante zera Contratada
                            setForm((prev) =>
                              prev ? { ...prev, idContratante: id, idContratada: id > 0 ? 0 : prev.idContratada } : prev,
                            )
                          }}
                        >
                          <option value={0}>Selecione...</option>
                          {empresas.map((e) => (
                            <option key={`t-${e.id}`} value={e.id}>
                              {e.nome}
                            </option>
                          ))}
                        </select>
                      </div>
                    </div>
                    <div className="col-md-6">
                      <div className="form-group">
                        <label className="control-label">Contratada</label>
                        <select
                          className="form-control"
                          disabled={disabled}
                          value={form.idContratada || 0}
                          onChange={(e) => {
                            const id = Number(e.target.value) || 0
                            // Opção A: um lado por vez — escolher Contratada zera Contratante
                            setForm((prev) =>
                              prev ? { ...prev, idContratada: id, idContratante: id > 0 ? 0 : prev.idContratante } : prev,
                            )
                          }}
                        >
                          <option value={0}>Selecione...</option>
                          {empresas.map((e) => (
                            <option key={`d-${e.id}`} value={e.id}>
                              {e.nome}
                            </option>
                          ))}
                        </select>
                      </div>
                    </div>
                    <div className="col-md-6">
                      <div className="form-group">
                        <label className="control-label">
                          Data inicial<span style={{ color: 'red' }}>*</span>
                        </label>
                        <input
                          type="text"
                          className="form-control"
                          placeholder="dd/mm/aaaa"
                          maxLength={10}
                          disabled={disabled}
                          value={form.dataInicio}
                          onChange={(e) => setField('dataInicio', e.target.value)}
                        />
                      </div>
                    </div>
                    <div className="col-md-6">
                      <div className="form-group">
                        <label className="control-label">Data previsão final</label>
                        <input
                          type="text"
                          className="form-control"
                          placeholder="dd/mm/aaaa"
                          maxLength={10}
                          disabled={disabled}
                          value={form.dataPrevisaoFim}
                          onChange={(e) => setField('dataPrevisaoFim', e.target.value)}
                        />
                      </div>
                    </div>
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="obra-logo-box">
                    <label className="control-label">Logo da Contratada</label>
                    <span className="obra-logo-hint">
                      Formatos: .jpeg, .jpg, .bmp e .png — Tamanho máximo: 2MB
                    </span>
                    <div className="obra-logo-preview">
                      {fotoPreview ? (
                        <img src={fotoPreview} alt="Logo da contratada" />
                      ) : (
                        <span className="obra-logo-placeholder" aria-hidden>
                          +
                        </span>
                      )}
                      {!disabled ? (
                        <input
                          ref={fileRef}
                          type="file"
                          className="obra-logo-file"
                          accept=".png,.jpg,.jpeg,.bmp,image/png,image/jpeg,image/bmp"
                          onChange={(e) => void onLogoSelected(e.target.files?.[0] ?? null)}
                        />
                      ) : null}
                    </div>
                    {!disabled && fotoPreview ? (
                      <button type="button" className="btn btn-link obra-logo-remove" onClick={onRemoverLogo}>
                        Remover imagem
                      </button>
                    ) : null}
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="form-group">
                    <label className="control-label">
                      CEP<span style={{ color: 'red' }}>*</span>
                    </label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={9}
                      inputMode="numeric"
                      disabled={disabled || cepBusy}
                      value={form.cep}
                      onChange={(e) => {
                        const next = digitsOnly(e.target.value, 8)
                        setField('cep', next)
                        if (next.length === 8) void lookupCep(next)
                      }}
                      onBlur={() => void lookupCep(form.cep)}
                      placeholder={cepBusy ? 'Buscando…' : '00000000'}
                    />
                  </div>
                </div>
                <div className="col-md-8">
                  <div className="form-group">
                    <label className="control-label">Bairro</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.bairro}
                      onChange={(e) => setField('bairro', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-12">
                  <div className="form-group">
                    <label className="control-label">Logradouro</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.logradouro}
                      onChange={(e) => setField('logradouro', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-4">
                  <div className="form-group">
                    <label className="control-label">Número</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={5}
                      disabled={disabled}
                      value={form.numero}
                      onChange={(e) => setField('numero', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-8">
                  <div className="form-group">
                    <label className="control-label">Complemento</label>
                    <input
                      type="text"
                      className="form-control"
                      maxLength={50}
                      disabled={disabled}
                      value={form.complemento}
                      onChange={(e) => setField('complemento', e.target.value)}
                    />
                  </div>
                </div>
                <div className="col-md-6">
                  <div className="form-group">
                    <label className="control-label">
                      UF<span style={{ color: 'red' }}>*</span>
                    </label>
                    <select
                      className="form-control"
                      disabled={disabled}
                      value={form.idUf || 0}
                      onChange={(e) => void onUfChange(Number(e.target.value) || 0)}
                    >
                      <option value={0}>Selecione...</option>
                      {ufs.map((u) => (
                        <option key={u.id} value={u.id}>
                          {u.nome}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
                <div className="col-md-6">
                  <div className="form-group">
                    <label className="control-label">
                      Município<span style={{ color: 'red' }}>*</span>
                    </label>
                    <select
                      className="form-control"
                      disabled={disabled || form.idUf <= 0}
                      value={form.idMunicipio || 0}
                      onChange={(e) => setField('idMunicipio', Number(e.target.value) || 0)}
                    >
                      <option value={0}>Selecione...</option>
                      {municipios.map((m) => (
                        <option key={m.id} value={m.id}>
                          {m.nome}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>
            </form>

            {/* Paridade visual do lápis (Tarefa/Cadastro): lista-tarefas + header-table + .tabela */}
            <div className="lista-tarefas">
              <div className="col-xs-12 no-padding header-table">
                <h4>COLABORADORES</h4>
                <div className="pull-right">
                  <button
                    type="button"
                    className="btn btn-blue btn-block-xs"
                    disabled={!canManageVinculos}
                    title={
                      isNova
                        ? 'Salve a obra para adicionar colaboradores'
                        : !temEmpresa
                          ? 'Informe Contratante ou Contratada'
                          : undefined
                    }
                    onClick={() => openColaborador('novo')}
                  >
                    <i className="fa fa-users" aria-hidden /> ADICIONAR COLABORADOR
                  </button>
                </div>
              </div>
              {isNova ? (
                <p className="muted" style={{ clear: 'both', padding: '8px 0' }}>
                  Salve a obra para vincular colaboradores (igual produção: vínculos gravados com a obra).
                </p>
              ) : null}
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
                    {isNova || listBusy ? (
                      <tr>
                        <td colSpan={7}>
                          {listBusy ? 'Carregando…' : 'Nenhum registro encontrado.'}
                        </td>
                      </tr>
                    ) : colaboradores.length === 0 ? (
                      <tr>
                        <td colSpan={7}>Nenhum registro encontrado.</td>
                      </tr>
                    ) : (
                      colaboradores.map((col) => (
                        <tr key={col.idColaborador}>
                          <td>{col.nome || '—'}</td>
                          <td>{col.descricaoCargo || '—'}</td>
                          <td>{col.telefonePrincipal || '—'}</td>
                          <td>{col.email || '—'}</td>
                          <td>{col.descricaoGrupo || '—'}</td>
                          <td>
                            {col.editavel && !disabled ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Editar"
                                onClick={() => openColaborador('editar', col.idColaborador)}
                              >
                                <i className="fa fa-edit" aria-hidden />
                              </button>
                            ) : null}
                          </td>
                          <td>
                            {col.excluivel && !disabled ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Remover"
                                onClick={() => void onRemoveColaborador(col)}
                              >
                                <i className="fa fa-trash-o" aria-hidden />
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
                <div className="pull-right">
                  <button
                    type="button"
                    className="btn btn-blue btn-block-xs"
                    disabled={!canManageVinculos}
                    title={
                      isNova
                        ? 'Salve a obra para adicionar equipamentos'
                        : !temEmpresa
                          ? 'Informe Contratante ou Contratada'
                          : undefined
                    }
                    onClick={() => openEquipamento('novo')}
                  >
                    <i className="fa fa-cogs" aria-hidden /> ADICIONAR EQUIPAMENTOS
                  </button>
                </div>
              </div>
              {isNova ? (
                <p className="muted" style={{ clear: 'both', padding: '8px 0' }}>
                  Salve a obra para vincular equipamentos.
                </p>
              ) : null}
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
                    {isNova || listBusy ? (
                      <tr>
                        <td colSpan={8}>
                          {listBusy ? 'Carregando…' : 'Nenhum registro encontrado.'}
                        </td>
                      </tr>
                    ) : equipamentos.length === 0 ? (
                      <tr>
                        <td colSpan={8}>Nenhum registro encontrado.</td>
                      </tr>
                    ) : (
                      equipamentos.map((eq) => (
                        <tr key={eq.idObraEquipamento || eq.idEquipamento}>
                          <td>{eq.tipoEquipamento || '—'}</td>
                          <td>{eq.descricao || '—'}</td>
                          <td>{labelTipoAquisicao(eq.tipoAquisicao)}</td>
                          <td>{eq.fabricanteFornecedor || '—'}</td>
                          <td>{eq.contato || '—'}</td>
                          <td>{eq.telefone || '—'}</td>
                          <td>
                            {!disabled ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Editar"
                                onClick={() => openEquipamento('editar', eq.idEquipamento)}
                              >
                                <i className="fa fa-edit" aria-hidden />
                              </button>
                            ) : null}
                          </td>
                          <td>
                            {!disabled ? (
                              <button
                                type="button"
                                className="btn btn-simple btn-just-icon"
                                title="Remover"
                                onClick={() => void onRemoveEquipamento(eq)}
                              >
                                <i className="fa fa-trash-o" aria-hidden />
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

            <div className="col-xs-12 no-padding cadastro-form-actions obra-cadastro-actions">
              <button
                type="button"
                className="btn btn-blue"
                onClick={() => {
                  if (isNova) {
                    goOperador('/Obra/Escolher')
                    return
                  }
                  if (window.history.length > 1) {
                    window.history.back()
                    return
                  }
                  goOperador('/Obra/Index')
                }}
              >
                <i className="fa fa-arrow-left" aria-hidden />
                <span>Voltar</span>
              </button>
              {modo === 'visualizar' ? null : (
                <button
                  type="button"
                  className="btn btn-blue"
                  disabled={saving || disabled}
                  onClick={() => void onSave()}
                >
                  <i className="fa fa-check" aria-hidden />
                  <span>SALVAR</span>
                </button>
              )}
            </div>
          </>
        ) : null}
      </section>
    </OperadorShell>
  )
}
