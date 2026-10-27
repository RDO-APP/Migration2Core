using System.Net;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

/// <summary>Página de diagnóstico homolog — só Staging. Não altera telas P1–P5.</summary>
[AllowAnonymous]
public class HomologController : Controller
{
    private readonly IWebHostEnvironment _env;

    public HomologController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet("/Homolog/F12")]
    public IActionResult F12()
    {
        if (!_env.IsStaging())
        {
            return NotFound();
        }

        var snap = SafeSnapshot(HttpContext);
        var auth = User.Identity?.IsAuthenticated == true;
        var html = BuildF12Html(snap, auth);
        return Content(html, "text/html; charset=utf-8");
    }

    private static string SafeSnapshot(HttpContext ctx)
    {
        try
        {
            return HomologDiagnostics.BuildSnapshot(ctx);
        }
        catch (Exception ex)
        {
            return $"snapshot-erro; {ex.GetType().Name}: {WebUtility.HtmlEncode(ex.Message)}";
        }
    }

    private static string BuildF12Html(string snapshot, bool autenticado)
    {
        var sb = new StringBuilder();
        sb.Append("""
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Homolog — debug F12 (RDO P5a)</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 24px; max-width: 720px; line-height: 1.45; }
    h1 { font-size: 1.25rem; }
    pre { background: #1a1a2e; color: #eee; padding: 12px; overflow: auto; font-size: 13px; }
    .ok { color: #2e7d32; } .warn { color: #c62828; }
    ol li { margin-bottom: 8px; }
    a { color: #1565c0; }
  </style>
</head>
<body>
  <h1>Debug homolog — use com F12 aberto</h1>
  <p><strong>Não</strong> é tela de produto. Operador (Cards/RDO) fica igual ao legado.</p>
  <p class="warn">Meta: chegar na listagem RDO como prod <code>sistema.rdoapp.com.br/rdo/index</code>.</p>
  <h2>Snapshot servidor (esta requisição)</h2>
  <pre id="snap-server">
""");
        sb.Append(WebUtility.HtmlEncode(snapshot));
        sb.Append($"\nautenticado-mvc={autenticado.ToString().ToLowerInvariant()}");
        sb.Append("""
</pre>
  <h2>API JSON (Fetch/XHR)</h2>
  <pre id="snap-api">Carregando GET /api/bff/diag …</pre>
  <h2>Passos F12</h2>
  <ol>
    <li>Abra <strong>Rede</strong> → filtro <strong>Fetch/XHR</strong> (não use só <code>app/assets</code>).</li>
    <li>Clique <a href="/api/bff/diag" target="_blank" rel="noopener">/api/bff/diag</a> — copie JSON para o chat Migração.</li>
    <li>Teste RDO: <a href="/Rdo/Index" target="_blank" rel="noopener">/Rdo/Index</a> — se loop, abra Rede → <strong>Doc</strong> → cabeçalhos <code>X-RdoApp-Diag</code> / <code>X-RdoApp-Redirect-Motivo</code>.</li>
    <li>Log tentativas: <code>docs/migracao/homolog-p5-rdo-tentativas.md</code> (T3, T4…).</li>
  </ol>
  <p><a href="/Tarefa/Cards">Voltar Cards</a> · <a href="/Account/Login">Login</a></p>
  <script>
    fetch('/api/bff/diag', { credentials: 'include', headers: { Accept: 'application/json' } })
      .then(r => r.json())
      .then(j => { document.getElementById('snap-api').textContent = JSON.stringify(j, null, 2); console.info('[RDO homolog F12]', j); })
      .catch(e => { document.getElementById('snap-api').textContent = String(e); });
  </script>
</body>
</html>
""");
        return sb.ToString();
    }
}
