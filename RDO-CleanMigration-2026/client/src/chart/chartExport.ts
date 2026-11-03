export type ChartSerie = { key: string; name: string; color: string }

export type GroupedChartRow = {
  label: string
  values: Record<string, number>
}

export type SimpleBar = { label: string; value: number; color?: string }

function esc(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function downloadBlob(blob: Blob, filename: string) {
  const a = document.createElement('a')
  const url = URL.createObjectURL(blob)
  a.href = url
  a.download = filename
  a.click()
  setTimeout(() => URL.revokeObjectURL(url), 1500)
}

function svgSize(svg: string): { w: number; h: number } {
  const wm = svg.match(/width="([\d.]+)"/)
  const hm = svg.match(/height="([\d.]+)"/)
  return { w: Number(wm?.[1] ?? 900), h: Number(hm?.[1] ?? 500) }
}

export function buildGroupedChartSvg(
  title: string,
  rows: GroupedChartRow[],
  series: ChartSerie[],
  visible: Record<string, boolean>,
): string {
  const active = series.filter((s) => visible[s.key] !== false)
  const max = Math.max(
    1,
    ...rows.flatMap((r) => active.map((s) => Math.max(0, Number(r.values[s.key] ?? 0)))),
  )
  const nameW = 280
  const plotW = 620
  const pad = 16
  const barH = 14
  const gapBar = 4
  const groupPad = 10
  const groupH = Math.max(28, active.length * (barH + gapBar) + groupPad)
  const headerH = 44
  const legendH = 28
  const w = nameW + plotW + pad * 2
  const h = headerH + legendH + rows.length * groupH + pad
  const legend = active
    .map((s, i) => {
      const x = pad + i * 150
      return `<rect x="${x}" y="${headerH + 6}" width="10" height="10" fill="${s.color}"/><text x="${x + 14}" y="${headerH + 15}" font-size="11" fill="#333">${esc(s.name)}</text>`
    })
    .join('')
  const groups = rows
    .map((row, gi) => {
      const y0 = headerH + legendH + gi * groupH
      const name = `<text x="${pad}" y="${y0 + groupH / 2}" font-size="12" fill="#333">${esc(row.label)}</text>`
      const bars = active
        .map((s, si) => {
          const raw = Number(row.values[s.key] ?? 0)
          const n = Math.max(0, raw)
          const bw = (n / max) * (plotW - 36)
          const y = y0 + si * (barH + gapBar)
          const x = pad + nameW
          const inside = bw >= 40
          const labelFill =
            s.key === 'gerado' || s.key === 'assinado_contratada' || s.key === 'assinado_contratante'
              ? '#222'
              : '#fff'
          const val = inside
            ? `<text x="${x + bw - 4}" y="${y + 11}" font-size="11" text-anchor="end" fill="${labelFill}">${raw}</text>`
            : `<text x="${x + bw + 6}" y="${y + 11}" font-size="11" fill="#333">${raw}</text>`
          return `<rect x="${x}" y="${y}" width="${plotW - 36}" height="${barH}" fill="#f0f0f0"/><rect x="${x}" y="${y}" width="${bw}" height="${barH}" fill="${s.color}"/>${val}`
        })
        .join('')
      return `${name}${bars}`
    })
    .join('')
  return `<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><rect width="100%" height="100%" fill="#fff"/><text x="${pad}" y="28" font-size="16" font-weight="600" fill="#333">${esc(title)}</text>${legend}${groups}</svg>`
}

export function buildSimpleBarSvg(title: string, items: SimpleBar[]): string {
  const max = Math.max(1, ...items.map((i) => i.value))
  const nameW = 280
  const plotW = 520
  const pad = 16
  const rowH = 22
  const headerH = 40
  const w = nameW + plotW + pad * 2
  const h = headerH + items.length * rowH + pad
  const rows = items
    .map((item, i) => {
      const y = headerH + i * rowH
      const bw = (Math.max(0, item.value) / max) * (plotW - 40)
      const x = pad + nameW
      const color = item.color ?? '#28496f'
      return `<text x="${pad}" y="${y + 14}" font-size="12" fill="#333">${esc(item.label)}</text><rect x="${x}" y="${y + 4}" width="${plotW - 40}" height="12" fill="#eee"/><rect x="${x}" y="${y + 4}" width="${bw}" height="12" fill="${color}"/><text x="${x + plotW - 36}" y="${y + 14}" font-size="11" text-anchor="end" fill="#333">${item.value}</text>`
    })
    .join('')
  return `<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><rect width="100%" height="100%" fill="#fff"/><text x="${pad}" y="26" font-size="16" font-weight="600" fill="#333">${esc(title)}</text>${rows}</svg>`
}

function svgToCanvas(svg: string): Promise<HTMLCanvasElement> {
  const { w, h } = svgSize(svg)
  const blob = new Blob([svg], { type: 'image/svg+xml;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      canvas.width = Math.ceil(w)
      canvas.height = Math.ceil(h)
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        URL.revokeObjectURL(url)
        reject(new Error('Canvas indisponível.'))
        return
      }
      ctx.fillStyle = '#fff'
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.drawImage(img, 0, 0)
      URL.revokeObjectURL(url)
      resolve(canvas)
    }
    img.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('Falha ao renderizar o gráfico.'))
    }
    img.src = url
  })
}

function canvasToBlob(canvas: HTMLCanvasElement, type: string, quality?: number): Promise<Blob> {
  return new Promise((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (!blob) reject(new Error('Falha ao gerar imagem.'))
      else resolve(blob)
    }, type, quality)
  })
}

function jpegToPdf(jpeg: Uint8Array, width: number, height: number): Blob {
  const objects: Uint8Array[] = []
  const enc = new TextEncoder()
  const pageW = width
  const pageH = height
  const content = `q ${pageW} 0 0 ${pageH} 0 0 cm /Im0 Do Q\n`
  const contentBytes = enc.encode(content)

  function obj(body: string | Uint8Array): number {
    const bytes = typeof body === 'string' ? enc.encode(body) : body
    objects.push(bytes)
    return objects.length
  }

  obj('<< /Type /Catalog /Pages 2 0 R >>\n')
  obj('<< /Type /Pages /Count 1 /Kids [3 0 R] >>\n')
  obj(
    `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${pageW} ${pageH}] /Contents 4 0 R /Resources << /XObject << /Im0 5 0 R >> >> >>\n`,
  )
  obj(`<< /Length ${contentBytes.length} >>\nstream\n${content}endstream\n`)
  const imgHeader = enc.encode(
    `<< /Type /XObject /Subtype /Image /Width ${width} /Height ${height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length ${jpeg.length} >>\nstream\n`,
  )
  const imgTail = enc.encode('\nendstream\n')
  const imgObj = new Uint8Array(imgHeader.length + jpeg.length + imgTail.length)
  imgObj.set(imgHeader, 0)
  imgObj.set(jpeg, imgHeader.length)
  imgObj.set(imgTail, imgHeader.length + jpeg.length)
  obj(imgObj)

  const header = enc.encode('%PDF-1.3\n')
  const chunks: Uint8Array[] = [header]
  const offsets = [0]
  let pos = header.length
  for (let i = 0; i < objects.length; i++) {
    const line = enc.encode(`${i + 1} 0 obj\n`)
    offsets.push(pos)
    chunks.push(line)
    pos += line.length
    chunks.push(objects[i])
    pos += objects[i].length
    const end = enc.encode('endobj\n')
    chunks.push(end)
    pos += end.length
  }
  const xrefPos = pos
  let xref = `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`
  for (let i = 1; i <= objects.length; i++) {
    xref += `${String(offsets[i]).padStart(10, '0')} 00000 n \n`
  }
  xref += `trailer<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefPos}\n%%EOF\n`
  chunks.push(enc.encode(xref))
  const total = chunks.reduce((n, c) => n + c.length, 0)
  const out = new Uint8Array(total)
  let o = 0
  for (const c of chunks) {
    out.set(c, o)
    o += c.length
  }
  return new Blob([out], { type: 'application/pdf' })
}

export async function exportChart(
  kind: 'print' | 'png' | 'jpeg' | 'pdf' | 'svg',
  svg: string,
  filename: string,
): Promise<void> {
  if (kind === 'svg') {
    downloadBlob(new Blob([svg], { type: 'image/svg+xml;charset=utf-8' }), `${filename}.svg`)
    return
  }
  if (kind === 'print') {
    const w = window.open('', '_blank', 'noopener,noreferrer')
    if (!w) {
      window.print()
      return
    }
    w.document.write(
      `<!doctype html><html><head><title>${esc(filename)}</title></head><body style="margin:0">${svg}</body></html>`,
    )
    w.document.close()
    w.focus()
    w.print()
    return
  }
  const canvas = await svgToCanvas(svg)
  if (kind === 'png') {
    downloadBlob(await canvasToBlob(canvas, 'image/png'), `${filename}.png`)
    return
  }
  const jpegBlob = await canvasToBlob(canvas, 'image/jpeg', 0.92)
  if (kind === 'jpeg') {
    downloadBlob(jpegBlob, `${filename}.jpeg`)
    return
  }
  const buf = new Uint8Array(await jpegBlob.arrayBuffer())
  downloadBlob(jpegToPdf(buf, canvas.width, canvas.height), `${filename}.pdf`)
}
