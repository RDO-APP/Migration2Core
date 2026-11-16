import type {
  TarefaCadastro,
  TarefaCadastroImagem,
  TarefaCadastroSaveRequest,
  TarefaLookup,
} from './api/equipamentos-api.types'

export const STATUS_PLANEJADA = 1
export const STATUS_PAUSADA = 4

export function maskDateInput(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 8)
  if (digits.length <= 2) return digits
  if (digits.length <= 4) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return `${digits.slice(0, 2)}/${digits.slice(2, 4)}/${digits.slice(4)}`
}

export function maskTimeInput(value: string): string {
  const digits = value.replace(/\D/g, '').slice(0, 4)
  if (digits.length <= 2) return digits
  return `${digits.slice(0, 2)}:${digits.slice(2)}`
}

export function todayBr(): string {
  const d = new Date()
  const dd = String(d.getDate()).padStart(2, '0')
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  return `${dd}/${mm}/${d.getFullYear()}`
}

export function horimetroTotal(inicial: number, final: number): number {
  const t = Number((final - inicial).toFixed(1))
  return t > 0 ? t : 0
}

export function statusOptionsFor(
  all: TarefaLookup[],
  currentStatus: number,
  novaMedicao: boolean,
): TarefaLookup[] {
  if (novaMedicao || currentStatus !== STATUS_PLANEJADA) {
    return all.filter((s) => s.id !== STATUS_PLANEJADA)
  }
  return all
}

export function buildSaveRequest(
  data: TarefaCadastro,
  form: {
    descricao: string
    idEtapa: number
    status: number
    idUnidade: number
    dataInicio: string
    dataPrevisaoFim: string
    qtdPlanejada: number
    valor: number
    qtdConstruida: number
    dataMedicao: string
    horaInicial: string
    horaFinal: string
    horimetroInicial: number
    horimetroFinal: number
    comentario: string
    codigoParalizacao: string
    listaIdsObraColaborador?: number[]
    listaIdsObraEquipamento?: number[]
    listaAcidentes?: TarefaCadastro['listaAcidentes']
    listaIdsAcidentesRemovidos?: number[]
    listaImagens?: TarefaCadastroImagem[]
  },
  novaMedicao: boolean,
): TarefaCadastroSaveRequest {
  const horimetroTotalVal = horimetroTotal(form.horimetroInicial, form.horimetroFinal)
  return {
    id: data.id,
    novaMedicao,
    descricao: form.descricao.trim(),
    idEtapa: form.idEtapa,
    status: form.status,
    idUnidade: form.idUnidade,
    dataInicio: form.dataInicio,
    dataPrevisaoFim: form.dataPrevisaoFim,
    qtdPlanejada: form.qtdPlanejada,
    valor: form.valor,
    qtdConstruida: form.qtdConstruida,
    dataMedicao: form.dataMedicao,
    horaInicial: form.horaInicial,
    horaFinal: form.horaFinal,
    horimetroInicial: form.horimetroInicial,
    horimetroFinal: form.horimetroFinal,
    horimetroTotal: horimetroTotalVal,
    comentario: form.comentario,
    codigoParalizacao: form.codigoParalizacao,
    listaIdsObraColaborador: form.listaIdsObraColaborador,
    listaIdsObraEquipamento: form.listaIdsObraEquipamento,
    listaAcidentes: form.listaAcidentes,
    listaIdsAcidentesRemovidos: form.listaIdsAcidentesRemovidos,
    // id 0 = foto nova (nunca -Date.now(): estoura Int32 no BFF).
    listaImagens: form.listaImagens
      ?.filter((img) => !!img.base64)
      .map((img) => ({
        id: img.id > 0 ? img.id : 0,
        href: img.href?.startsWith('blob:') ? undefined : img.href,
        base64: img.base64,
        filetype: img.filetype,
      })),
  }
}

/** Contador negativo pequeno (cabe em Int32) — só UI local. */
let nextTempImagemId = -1

export function readFileAsBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => {
      const raw = String(reader.result ?? '')
      const i = raw.indexOf(',')
      resolve(i >= 0 ? raw.slice(i + 1) : raw)
    }
    reader.onerror = () => reject(reader.error ?? new Error('Falha ao ler arquivo.'))
    reader.readAsDataURL(file)
  })
}

export async function fileToTarefaImagem(file: File): Promise<TarefaCadastroImagem> {
  const base64 = await readFileAsBase64(file)
  const id = nextTempImagemId
  nextTempImagemId -= 1
  if (nextTempImagemId < -1_000_000) nextTempImagemId = -1
  return {
    id,
    href: URL.createObjectURL(file),
    base64,
    filetype: file.type || 'image/jpeg',
  }
}

export function validateTarefaForm(form: {
  descricao: string
  idEtapa: number
  status: number
  dataInicio: string
  dataPrevisaoFim: string
  dataMedicao: string
  codigoParalizacao: string
  novaMedicao: boolean
}): string | null {
  if (form.descricao.trim().length < 3) {
    return 'Por favor, introduza pelo menos três caracteres na Descrição da Tarefa.'
  }
  if (form.idEtapa <= 0) {
    return 'A Etapa deve ser preenchida.'
  }
  if (form.status <= 0) {
    return 'O Status deve ser preenchido.'
  }
  if (form.status === STATUS_PAUSADA && !form.codigoParalizacao.trim()) {
    return 'O Código de Paralização deve ser preenchido.'
  }
  if (form.dataInicio.replace(/\D/g, '').length < 8) {
    return 'A Data Inicial Planejada deve ser preenchida.'
  }
  if (form.dataPrevisaoFim.replace(/\D/g, '').length < 8) {
    return 'A Data Final Planejada deve ser preenchida.'
  }
  if ((form.novaMedicao || form.status !== STATUS_PLANEJADA) && form.dataMedicao.replace(/\D/g, '').length < 8) {
    return 'A Data da medição deve ser preenchida.'
  }
  return null
}
