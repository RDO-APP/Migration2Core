/** Paridade prod `toastr` — canto superior direito. Fila no módulo (sobrevive remount). */

export type ToastKind = 'success' | 'error'

export type ToastItem = { id: number; kind: ToastKind; message: string }

export type VisibleToast = ToastItem & { leaving: boolean }

const FLASH_KEY = 'rdoapp.flashToast'
const SHOW_MS = 2500
const HIDE_MS = 1000

type Listener = (items: VisibleToast[]) => void
const listeners = new Set<Listener>()
const current: VisibleToast[] = []
let seq = 1

function snapshot(): VisibleToast[] {
  return current.map((t) => ({ ...t }))
}

function emit(): void {
  const items = snapshot()
  listeners.forEach((fn) => fn(items))
}

export function subscribeToast(fn: Listener): () => void {
  listeners.add(fn)
  fn(snapshot())
  return () => {
    listeners.delete(fn)
  }
}

export function showToast(kind: ToastKind, message: string): void {
  const text = message.trim()
  if (!text) return
  const item: VisibleToast = { id: seq++, kind, message: text, leaving: false }
  current.push(item)
  emit()
  window.setTimeout(() => {
    const t = current.find((x) => x.id === item.id)
    if (t) t.leaving = true
    emit()
  }, SHOW_MS)
  window.setTimeout(() => {
    const i = current.findIndex((x) => x.id === item.id)
    if (i >= 0) current.splice(i, 1)
    emit()
  }, SHOW_MS + HIDE_MS)
}

/** Sobrevive a `goOperador` (reload full page). */
export function flashToast(kind: ToastKind, message: string): void {
  const text = message.trim()
  if (!text) return
  try {
    sessionStorage.setItem(FLASH_KEY, JSON.stringify({ kind, message: text }))
  } catch {
    showToast(kind, text)
  }
}

export function consumeFlashToast(): { kind: ToastKind; message: string } | null {
  try {
    const raw = sessionStorage.getItem(FLASH_KEY)
    if (!raw) return null
    sessionStorage.removeItem(FLASH_KEY)
    const parsed = JSON.parse(raw) as { kind?: string; message?: string }
    if (parsed.kind !== 'success' && parsed.kind !== 'error') return null
    if (!parsed.message?.trim()) return null
    return { kind: parsed.kind, message: parsed.message.trim() }
  } catch {
    return null
  }
}

export const TOAST_SHOW_MS = SHOW_MS
export const TOAST_HIDE_MS = HIDE_MS
