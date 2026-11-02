import { useEffect, useState } from 'react'
import { createPortal } from 'react-dom'
import {
  consumeFlashToast,
  showToast,
  subscribeToast,
  type VisibleToast,
} from '../toast'
import '../toast.css'

export function ToastHost() {
  const [items, setItems] = useState<VisibleToast[]>([])

  useEffect(() => {
    const unsub = subscribeToast(setItems)
    const flash = consumeFlashToast()
    if (flash) showToast(flash.kind, flash.message)
    return unsub
  }, [])

  if (items.length === 0 || typeof document === 'undefined') return null

  return createPortal(
    <div id="rdo-toast-host" aria-live="polite">
      {items.map((t) => (
        <div
          key={t.id}
          className={`rdo-toast rdo-toast-${t.kind}${t.leaving ? ' rdo-toast-leaving' : ''}`}
          role={t.kind === 'error' ? 'alert' : 'status'}
        >
          <div className="rdo-toast-message">{t.message}</div>
        </div>
      ))}
    </div>,
    document.body,
  )
}
