import { useCallback, useState, type ReactNode } from 'react'
import './confirm-dialog.css'

type Pending = { message: string; resolve: (ok: boolean) => void }

/** Paridade prod `MensagemConfirmacao` / `MsgAlerta` tipo C — não usar `window.confirm`. */
export function useConfirmDialog(): {
  ask: (message: string) => Promise<boolean>
  dialog: ReactNode
} {
  const [pending, setPending] = useState<Pending | null>(null)

  const ask = useCallback((message: string) => {
    return new Promise<boolean>((resolve) => {
      setPending({ message, resolve })
    })
  }, [])

  function close(ok: boolean) {
    pending?.resolve(ok)
    setPending(null)
  }

  const dialog = pending ? (
    <div className="rdo-confirm-backdrop" role="presentation">
      <div
        className="rdo-confirm"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="rdo-confirm-title"
        aria-describedby="rdo-confirm-body"
      >
        <div className="rdo-confirm-header">
          <h4 id="rdo-confirm-title">CONFIRMAÇÃO</h4>
        </div>
        <div className="rdo-confirm-body" id="rdo-confirm-body">
          {pending.message}
        </div>
        <div className="rdo-confirm-footer">
          <button type="button" className="rdo-confirm-nao" onClick={() => close(false)}>
            NÃO
          </button>
          <button type="button" className="rdo-confirm-sim" autoFocus onClick={() => close(true)}>
            SIM
          </button>
        </div>
      </div>
    </div>
  ) : null

  return { ask, dialog }
}
