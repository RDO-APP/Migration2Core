import type { TarefaCadastro, TarefaCadastroSaveRequest, TarefaCadastroSaveResult, TarefaStatusUpdateResult, TarefaStatusMassaResult } from './equipamentos-api.types'

async function readJson<T>(res: Response, fallback: string): Promise<T> {
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let fromJson: string | undefined
    try {
      const j = JSON.parse(text) as { message?: string; errorMessage?: string }
      fromJson = j.message || j.errorMessage
    } catch {
      /* HTML ou texto puro */
    }
    const short =
      fromJson?.trim() ||
      (text.includes('<!DOCTYPE') || text.includes('<html')
        ? `Erro ${res.status} no servidor (${fallback}).`
        : text.slice(0, 400) || `Erro ${res.status} (${fallback}).`)
    throw new Error(short)
  }
  return res.json() as Promise<T>
}

export async function fetchTarefaCadastro(id: number): Promise<TarefaCadastro> {
  const res = await fetch(`/api/bff/tarefas/${id}`, {
    credentials: 'include',
    headers: { Accept: 'application/json' },
  })
  return readJson(res, 'cadastro tarefa')
}

export async function saveTarefaCadastro(
  body: TarefaCadastroSaveRequest,
): Promise<TarefaCadastroSaveResult> {
  const res = await fetch('/api/bff/tarefas', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  return readJson(res, 'salvar tarefa')
}

export async function downloadRelatorioHorasEquipamento(
  tarefaId: number,
  body: { dataInicial: string; dataFinal: string; tipoRelatorio: 'PDF' | 'Excel'; descricaoTarefa: string },
): Promise<void> {
  const res = await fetch(`/api/bff/tarefas/${tarefaId}/relatorio-horas-equipamento`, {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: '*/*', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = await res.text()
    let fromJson: string | undefined
    try {
      const j = JSON.parse(text) as { message?: string }
      fromJson = j.message
    } catch {
      /* texto */
    }
    throw new Error(fromJson?.trim() || `Erro ${res.status} ao gerar relatório.`)
  }
  const blob = await res.blob()
  const cd = res.headers.get('Content-Disposition') ?? ''
  const star = /filename\*=UTF-8''([^;]+)/i.exec(cd)
  const quoted = /filename="?([^";]+)"?/i.exec(cd)
  const name = decodeURIComponent(
    star?.[1] ?? quoted?.[1] ?? `relatorio-horas.${body.tipoRelatorio === 'Excel' ? 'xls' : 'pdf'}`,
  )
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = name
  a.click()
  URL.revokeObjectURL(url)
}

export async function atualizarStatusTarefa(
  tarefaId: number,
  idStatus: number,
): Promise<TarefaStatusUpdateResult> {
  const res = await fetch(`/api/bff/tarefas/${tarefaId}/status`, {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ idStatus }),
  })
  return readJson(res, 'atualizar status')
}

export async function atualizarStatusTarefasEmMassa(
  ids: number[],
  idStatus: number,
): Promise<TarefaStatusMassaResult> {
  const res = await fetch('/api/bff/tarefas/status-em-massa', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ ids, idStatus }),
  })
  return readJson(res, 'status em massa')
}
