import { useEffect, useRef, useState } from 'react'
import { fetchTarefaCadastro, saveTarefaCadastro } from '../api/tarefaApi'
import type { TarefaCadastro, TarefaCadastroImagem } from '../api/equipamentos-api.types'
import { showToast } from '../toast'
import {
  STATUS_PAUSADA,
  buildSaveRequest,
  horimetroTotal,
  maskDateInput,
  maskTimeInput,
  statusOptionsFor,
  todayBr,
  validateTarefaForm,
} from '../tarefaCadastroShared'

type NovaMedicaoModalProps = {
  tarefaId: number
  descricaoTarefa: string
  onClose: () => void
  onSaved: () => void
}

export function NovaMedicaoModal({ tarefaId, descricaoTarefa, onClose, onSaved }: NovaMedicaoModalProps) {
  const [data, setData] = useState<TarefaCadastro | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [status, setStatus] = useState(0)
  const [dataMedicao, setDataMedicao] = useState(todayBr())
  const [horaInicial, setHoraInicial] = useState('')
  const [horaFinal, setHoraFinal] = useState('')
  const [qtdConstruida, setQtdConstruida] = useState(0)
  const [horimetroInicial, setHorimetroInicial] = useState(0)
  const [horimetroFinal, setHorimetroFinal] = useState(0)
  const [comentario, setComentario] = useState('')
  const [codigoParalizacao, setCodigoParalizacao] = useState('')
  const [fotos, setFotos] = useState<TarefaCadastroImagem[]>([])
  const [fotoNome, setFotoNome] = useState('')
  const fileRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    let cancelled = false
    fetchTarefaCadastro(tarefaId)
      .then((dto) => {
        if (cancelled) return
        setData(dto)
        setStatus(dto.status === 1 ? 0 : dto.status)
        setHorimetroInicial(dto.ultimoHorimetroFinal ?? dto.horimetroFinal ?? 0)
      })
      .catch((e: unknown) => {
        if (!cancelled) setError(e instanceof Error ? e.message : 'Falha ao carregar medição.')
      })
      .finally(() => {
        if (!cancelled) setLoading(false)
      })
    return () => {
      cancelled = true
    }
  }, [tarefaId])

  const statusOpts = statusOptionsFor(data?.statusTarefa ?? [], data?.status ?? 0, true)
  const locked = data?.rdoAssinado === true
  const totalH = horimetroTotal(horimetroInicial, horimetroFinal)

  async function onSave() {
    if (!data) return
    const msg = validateTarefaForm({
      descricao: data.descricao,
      idEtapa: data.idEtapa,
      status,
      dataInicio: data.dataInicio,
      dataPrevisaoFim: data.dataPrevisaoFim,
      dataMedicao,
      codigoParalizacao,
      novaMedicao: true,
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
            descricao: data.descricao,
            idEtapa: data.idEtapa,
            status,
            idUnidade: data.idUnidade,
            dataInicio: data.dataInicio,
            dataPrevisaoFim: data.dataPrevisaoFim,
            qtdPlanejada: data.qtdPlanejada,
            valor: data.valor,
            qtdConstruida,
            dataMedicao,
            horaInicial,
            horaFinal,
            horimetroInicial,
            horimetroFinal,
            comentario,
            codigoParalizacao,
          },
          true,
        ),
      )
      if (!result.ok) {
        showToast('error', result.errorMessage || 'Não foi possível salvar.')
        return
      }
      showToast('success', 'Registro salvo com sucesso.')
      onSaved()
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Não foi possível salvar.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="tarefa-modal-backdrop" role="presentation" onClick={onClose}>
      <div
        className="tarefa-modal"
        role="dialog"
        aria-labelledby="nova-medicao-titulo"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="tarefa-modal-header">
          <h4 id="nova-medicao-titulo">NOVA MEDIÇÃO - {descricaoTarefa}</h4>
          <button type="button" className="btn btn-simple" onClick={onClose} title="Fechar">
            <i className="icon-close" aria-hidden="true" />
          </button>
        </div>
        <div className="tarefa-modal-body">
          {loading ? <p className="muted">Carregando…</p> : null}
          {error ? <p className="error">{error}</p> : null}
          {data ? (
            <div className="row">
              <div className="col-md-3 col-sm-12">
                <div className="form-group">
                  <label className="control-label">
                    Status<span style={{ color: 'red' }}>*</span>
                  </label>
                  <select
                    className="form-control"
                    value={status}
                    disabled={locked}
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
                      disabled={locked}
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
                    disabled={locked}
                    onChange={(e) => setDataMedicao(maskDateInput(e.target.value))}
                  />
                </div>
              </div>
              <div className="col-md-3 col-sm-12">
                <div className="form-group">
                  <label className="control-label">Hora Inicial</label>
                  <input
                    className="form-control"
                    value={horaInicial}
                    disabled={locked}
                    placeholder=""
                    onChange={(e) => setHoraInicial(maskTimeInput(e.target.value))}
                  />
                </div>
              </div>
              <div className="col-md-3 col-sm-12">
                <div className="form-group">
                  <label className="control-label">Hora Final</label>
                  <input
                    className="form-control"
                    value={horaFinal}
                    disabled={locked}
                    placeholder=""
                    onChange={(e) => setHoraFinal(maskTimeInput(e.target.value))}
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
                    disabled={locked || (status !== 1 && status !== 2 && status !== 3)}
                    onChange={(e) => setQtdConstruida(Number(e.target.value))}
                  />
                </div>
              </div>
              <div className="col-md-3 col-sm-12">
                <div className="form-group">
                  <label className="control-label">Horímetro Inicial</label>
                  <input
                    className="form-control"
                    readOnly
                    value={loading ? 'Carregando...' : horimetroInicial}
                    disabled={locked || loading}
                  />
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
                    disabled={locked}
                    onChange={(e) => setHorimetroFinal(Number(e.target.value))}
                  />
                </div>
              </div>
              <div className="col-md-3 col-sm-12">
                <div className="form-group">
                  <label className="control-label">Total Horas</label>
                  <input className="form-control" readOnly value={totalH} disabled={locked} />
                </div>
              </div>
              <div className="col-md-12">
                <div className="form-group">
                  <label className="control-label">Comentário</label>
                  <textarea
                    className="form-control"
                    rows={3}
                    maxLength={1400}
                    value={comentario}
                    disabled={locked}
                    onChange={(e) => setComentario(e.target.value)}
                  />
                </div>
              </div>
              {status !== 1 ? (
                <div className="col-md-12 tarefa-foto-bloco">
                  <label className="control-label">Foto</label>
                  <div className="tarefa-foto-row">
                    <input
                      ref={fileRef}
                      type="file"
                      accept=".png,.jpg,.jpeg,.bmp"
                      className="sr-only"
                      onChange={(e) => {
                        const f = e.target.files?.[0]
                        if (!f) {
                          setFotoNome('')
                          return
                        }
                        if (f.size > 2 * 1024 * 1024) {
                          showToast('error', 'O tamanho máximo da imagem é de 2MB.')
                          return
                        }
                        setFotoNome(f.name)
                      }}
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
                    <button type="button" className="btn btn-blue" onClick={() => fileRef.current?.click()}>
                      ESCOLHER ARQUIVO
                    </button>
                    <button
                      type="button"
                      className="btn btn-blue"
                      onClick={() => {
                        const file = fileRef.current?.files?.[0]
                        if (!file) {
                          showToast('error', 'Selecione um arquivo.')
                          return
                        }
                        if (file.size > 2 * 1024 * 1024) {
                          showToast('error', 'O tamanho máximo da imagem é de 2MB.')
                          return
                        }
                        setFotos((prev) => [...prev, { id: -Date.now(), href: URL.createObjectURL(file) }])
                        setFotoNome('')
                        if (fileRef.current) fileRef.current.value = ''
                      }}
                    >
                      <i className="fa fa-picture-o" aria-hidden="true" /> ADICIONAR FOTO
                    </button>
                  </div>
                  {fotos.length > 0 ? (
                    <section className="galeria rdo-galeria">
                      {fotos.map((img) => (
                        <div key={img.id} className="rdo-galeria-item">
                          <label>
                            <img src={img.href} alt="" />
                          </label>
                        </div>
                      ))}
                    </section>
                  ) : null}
                </div>
              ) : null}
            </div>
          ) : null}
        </div>
        <div className="tarefa-modal-footer">
          {!locked ? (
            <button type="button" className="btn btn-blue" disabled={saving || loading} onClick={() => void onSave()}>
              <i className="fa fa-save" aria-hidden="true" /> SALVAR
            </button>
          ) : null}
          <button type="button" className="btn btn-simple" onClick={onClose}>
            × CANCELAR
          </button>
        </div>
      </div>
    </div>
  )
}
