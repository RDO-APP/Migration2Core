import { detectOperadorPage } from './route'

/** Faixa + Console — só homolog.sistema.rdoapp.com.br */
export function initHomologDiag(): void {
  const host = window.location.hostname
  if (!host.includes('homolog.sistema.rdoapp.com.br')) {
    return
  }

  const page = detectOperadorPage()
  const linha = `[RDO homolog] pagina=${page} path=${window.location.pathname}`
  console.info(linha)

  let bar = document.getElementById('rdo-homolog-diag')
  if (!bar) {
    bar = document.createElement('div')
    bar.id = 'rdo-homolog-diag'
    bar.setAttribute(
      'style',
      'position:fixed;bottom:0;left:0;right:0;z-index:99999;background:#1a1a2e;color:#eee;font:12px/1.4 monospace;padding:6px 10px;border-top:2px solid #4caf50;',
    )
    document.body.appendChild(bar)
  }

  bar.textContent = `${linha} · F12 Console + Rede (Fetch/XHR: api/bff/diag) · tentativas: docs/migracao/homolog-p5-rdo-tentativas.md`

  fetch('/api/bff/diag', { credentials: 'include', headers: { Accept: 'application/json' } })
    .then((r) => r.json())
    .then((j: { snapshot?: string }) => {
      console.info('[RDO homolog diag API]', j)
      if (j.snapshot && bar) {
        bar.textContent = `${linha} · ${j.snapshot}`
      }
    })
    .catch((e) => console.warn('[RDO homolog diag API falhou]', e))
}
