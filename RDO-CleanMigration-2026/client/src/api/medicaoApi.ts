/** Paridade prod POST api/medicao/gerarrelatorio + Download.base64 */

function triggerDownload(blob: Blob, fileName: string) {
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  link.rel = 'noopener'
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}

export async function downloadMedicaoRelatorio(body: {
  dataInicial: string
  dataFinal: string
  tipoRelatorio: 'PDF' | 'Excel'
}): Promise<void> {
  const res = await fetch('/api/bff/medicao/relatorio', {
    method: 'POST',
    credentials: 'include',
    headers: { Accept: '*/*', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  })
  if (res.status === 401) {
    throw new Error('Sessão expirada ou obra não selecionada. Volte a Escolher obra.')
  }
  if (!res.ok) {
    const text = (await res.text()).trim()
    let detail = text
    try {
      const j = JSON.parse(text) as { message?: string; title?: string; detail?: string }
      detail = j.message || j.detail || j.title || text
    } catch {
      /* keep raw */
    }
    const snippet = (detail || '(corpo vazio)').slice(0, 400)
    throw new Error(`Erro ${res.status} ao gerar relatório de medição: ${snippet}`)
  }
  const blob = await res.blob()
  const cd = res.headers.get('Content-Disposition') ?? ''
  const match = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/.exec(cd)
  let fileName =
    body.tipoRelatorio === 'Excel'
      ? `Medicao_${body.dataInicial}_${body.dataFinal}.xls`
      : `Medicao_${body.dataInicial}_${body.dataFinal}.pdf`
  if (match?.[1]) {
    fileName = match[1].replace(/['"]/g, '').trim()
  }
  triggerDownload(blob, fileName)
}
