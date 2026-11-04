import type { EtapaComTarefas, TarefaCard } from './api/equipamentos-api.types'

export type CardsFiltroState = {
  descricao: string
  dataInicial: string
  dataFinalPlanejada: string
  statusTarefa: number
  dataInicialExecutada: string
  dataFinalExecutada: string
  idEtapa: number
}

export const EMPTY_FILTRO: CardsFiltroState = {
  descricao: '',
  dataInicial: '',
  dataFinalPlanejada: '',
  statusTarefa: 0,
  dataInicialExecutada: '',
  dataFinalExecutada: '',
  idEtapa: 0,
}

export const STATUS_FILTRO = [
  { id: 1, nome: 'Planejada' },
  { id: 2, nome: 'Em Execução' },
  { id: 3, nome: 'Finalizada' },
  { id: 4, nome: 'Pausada' },
  { id: 5, nome: 'Cancelada' },
]

/** dd/MM/yyyy → Date local ou null */
export function parseBrDate(value: string): Date | null {
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(value.trim())
  if (!m) return null
  const d = new Date(Number(m[3]), Number(m[2]) - 1, Number(m[1]))
  if (d.getFullYear() !== Number(m[3]) || d.getMonth() !== Number(m[2]) - 1 || d.getDate() !== Number(m[1])) {
    return null
  }
  return d
}

function dayTime(d: Date): number {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime()
}

function matchPlanejada(t: TarefaCard, f: CardsFiltroState): boolean {
  const ini = parseBrDate(f.dataInicial)
  const fim = parseBrDate(f.dataFinalPlanejada)
  const tIni = parseBrDate(t.dataInicio ?? '')
  const tFim = parseBrDate(t.dataPrevisaoFim ?? '')
  if (ini && fim) {
    if (!tIni || !tFim) return false
    return dayTime(tIni) >= dayTime(ini) && dayTime(tFim) <= dayTime(fim)
  }
  if (ini) {
    if (!tIni) return false
    return dayTime(tIni) === dayTime(ini)
  }
  if (fim) {
    if (!tFim) return false
    return dayTime(tFim) === dayTime(fim)
  }
  return true
}

/** Aproxima tar_dt_medicao com período primeira/última execução do card. */
function matchExecutada(t: TarefaCard, f: CardsFiltroState): boolean {
  const ini = parseBrDate(f.dataInicialExecutada)
  const fim = parseBrDate(f.dataFinalExecutada)
  if (!ini && !fim) return true
  if (!t.existeExecucao) return false
  const p = parseBrDate(t.primeiraExecucao ?? '')
  const u = parseBrDate(t.ultimaExecucao ?? '')
  if (ini && fim) {
    if (!p || !u) return false
    return dayTime(p) >= dayTime(ini) && dayTime(u) <= dayTime(fim)
  }
  if (ini) {
    const d = dayTime(ini)
    return (p != null && dayTime(p) === d) || (u != null && dayTime(u) === d)
  }
  if (fim) {
    const d = dayTime(fim)
    return (p != null && dayTime(p) === d) || (u != null && dayTime(u) === d)
  }
  return true
}

export function tarefaPassaFiltro(t: TarefaCard, f: CardsFiltroState): boolean {
  const desc = f.descricao.trim().toLowerCase()
  if (desc && !(t.descricao ?? '').toLowerCase().includes(desc)) return false
  if (f.statusTarefa > 0 && t.status !== f.statusTarefa) return false
  if (!matchPlanejada(t, f)) return false
  if (!matchExecutada(t, f)) return false
  return true
}

export function aplicarFiltroEtapas(
  etapas: EtapaComTarefas[],
  f: CardsFiltroState,
): EtapaComTarefas[] {
  const filtradas = etapas
    .filter((e) => (f.idEtapa > 0 ? e.id === f.idEtapa : true))
    .map((e) => ({
      ...e,
      tarefas: e.tarefas.filter((t) => tarefaPassaFiltro(t, f)),
    }))
    .filter((e) => e.tarefas.length > 0)
  return filtradas
}
