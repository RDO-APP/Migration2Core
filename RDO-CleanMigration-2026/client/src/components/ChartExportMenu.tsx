import { useEffect, useRef, useState } from 'react'
import { exportChart } from '../chart/chartExport'
import { showToast } from '../toast'

const ITEMS: { kind: 'print' | 'png' | 'jpeg' | 'pdf' | 'svg'; label: string; sep?: boolean }[] = [
  { kind: 'print', label: 'Print chart' },
  { kind: 'png', label: 'Download PNG image', sep: true },
  { kind: 'jpeg', label: 'Download JPEG image' },
  { kind: 'pdf', label: 'Download PDF document' },
  { kind: 'svg', label: 'Download SVG vector image' },
]

export function ChartExportMenu({
  filename,
  getSvg,
}: {
  filename: string
  getSvg: () => string
}) {
  const [open, setOpen] = useState(false)
  const rootRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    function onDoc(e: MouseEvent) {
      if (rootRef.current && !rootRef.current.contains(e.target as Node)) {
        setOpen(false)
      }
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') setOpen(false)
    }
    document.addEventListener('mousedown', onDoc)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDoc)
      document.removeEventListener('keydown', onKey)
    }
  }, [open])

  async function run(kind: (typeof ITEMS)[number]['kind']) {
    setOpen(false)
    try {
      await exportChart(kind, getSvg(), filename)
    } catch (e: unknown) {
      showToast('error', e instanceof Error ? e.message : 'Falha ao exportar o gráfico.')
    }
  }

  return (
    <div className="chart-export" ref={rootRef}>
      <button
        type="button"
        className="chart-export-btn"
        title="Chart context menu"
        aria-haspopup="menu"
        aria-expanded={open}
        onClick={() => setOpen((v) => !v)}
      >
        <span className="chart-export-bars" aria-hidden />
      </button>
      {open ? (
        <ul className="chart-export-menu" role="menu">
          {ITEMS.map((item) => (
            <li key={item.kind} role="none" className={item.sep ? 'chart-export-sep' : undefined}>
              <button type="button" role="menuitem" onClick={() => void run(item.kind)}>
                {item.label}
              </button>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  )
}
