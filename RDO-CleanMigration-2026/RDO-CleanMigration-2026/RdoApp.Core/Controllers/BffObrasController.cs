using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/obras")]
public class BffObrasController : ControllerBase
{
    private readonly ObrasQueryService _obras;
    private readonly ObraIndexService _obraIndex;
    private readonly LoginObraService _loginObra;
    private readonly ObraCadastroService _cadastro;

    public BffObrasController(
        ObrasQueryService obras,
        ObraIndexService obraIndex,
        LoginObraService loginObra,
        ObraCadastroService cadastro)
    {
        _obras = obras;
        _obraIndex = obraIndex;
        _loginObra = loginObra;
        _cadastro = cadastro;
    }

    /// <summary>M4.4 — obras do colaborador logado (cookie session).</summary>
    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
        if (string.IsNullOrEmpty(loginDataJson))
        {
            return Unauthorized(new { message = "LoginData ausente — faça login novamente." });
        }

        var ctx = await _obras.GetEscolherAsync(colaboradorId, cancellationToken);
        if (ctx == null)
        {
            return NotFound(new { message = "Colaborador não encontrado." });
        }

        ctx.UsuarioNome = User.Identity?.Name ?? "";
        return Ok(ctx);
    }

    /// <summary>M4.4 — seleciona obra (mesma lógica POST /Obra/Selecionar).</summary>
    [HttpPost("selecionar")]
    public async Task<IActionResult> Selecionar([FromBody] SelecionarObraRequest body, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new SelecionarObraResponse { Success = false, ErrorMessage = "Sessão inválida." });
        }

        var idObra = body.IdObra;
        if (idObra <= 0)
        {
            return BadRequest(new SelecionarObraResponse { Success = false, ErrorMessage = "Obra inválida." });
        }

        var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
        var existingLogin = LoginSessionJson.TryDeserialize(loginDataJson);

        var result = await _loginObra.SelectObraAsync(colaboradorId, idObra, existingLogin, cancellationToken);
        if (!result.Success || result.LoginData == null)
        {
            return BadRequest(new SelecionarObraResponse
            {
                Success = false,
                ErrorMessage = result.ErrorMessage ?? "Não foi possível selecionar a obra.",
            });
        }

        HttpContext.Session.SetInt32(SessionKeys.ObraId, result.ObraId);
        HttpContext.Session.SetString(SessionKeys.ObraNome, result.ObraNome ?? string.Empty);
        HttpContext.Session.SetString(SessionKeys.ObraCidadeEstado, result.ObraCidadeEstado ?? string.Empty);
        HttpContext.Session.SetInt32(SessionKeys.ObraColaboradorId, result.ObraColaboradorId);

        if (LoginSessionJson.TrySerialize(result.LoginData, out var loginJson))
        {
            HttpContext.Session.SetString(SessionKeys.LoginData, loginJson);
        }

        return Ok(new SelecionarObraResponse
        {
            Success = true,
            RedirectUrl = Url.Action("Cards", "Tarefa") ?? "/Tarefa/Cards",
        });
    }




    [HttpGet("index/bootstrap")]
    public async Task<IActionResult> IndexBootstrap(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _obraIndex.BootstrapAsync(HttpContext, colaboradorId, obraNome, cancellationToken));
    }

    [HttpGet("index/municipios")]
    public async Task<IActionResult> IndexMunicipios([FromQuery] int idUf, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        return Ok(await _obraIndex.MunicipiosByUfAsync(idUf, cancellationToken));
    }

    /// <summary>Proxy ViaCEP (same-origin) — evita bloqueio do browser a viacep.com.br.</summary>
    [HttpGet("cep/{cep}")]
    public async Task<IActionResult> LookupCep(string cep, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var digits = new string((cep ?? "").Where(char.IsDigit).ToArray());
        if (digits.Length != 8)
        {
            return BadRequest(new { message = "CEP deve ter 8 dígitos." });
        }

        try
        {
            using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(12) };
            using var res = await http.GetAsync($"https://viacep.com.br/ws/{digits}/json/", cancellationToken);
            if (!res.IsSuccessStatusCode)
            {
                return BadRequest(new { message = "Falha ao consultar CEP." });
            }

            var json = await res.Content.ReadAsStringAsync(cancellationToken);
            return Content(json, "application/json");
        }
        catch (Exception)
        {
            return BadRequest(new { message = "Falha ao consultar CEP." });
        }
    }

    [HttpGet("lista")]
    public async Task<IActionResult> Lista(
        [FromQuery] string? descricao,
        [FromQuery] int idContratante = 0,
        [FromQuery] string? dataInicioDe = null,
        [FromQuery] string? dataInicioAte = null,
        [FromQuery] int idUf = 0,
        [FromQuery] int idMunicipio = 0,
        [FromQuery] int statusObra = 0,
        CancellationToken cancellationToken = default)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var filter = new ObraIndexFilterDto
        {
            Descricao = descricao,
            IdContratante = idContratante,
            DataInicioDe = dataInicioDe,
            DataInicioAte = dataInicioAte,
            IdUf = idUf,
            IdMunicipio = idMunicipio,
            StatusObra = statusObra,
        };
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _obraIndex.ListAsync(colaboradorId, filter, obraNome, cancellationToken));
    }

    [HttpDelete("{idObra:int}")]
    public async Task<IActionResult> Delete(int idObra, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new ObraIndexActionResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraIndexService.CanObraLista(HttpContext, "deletar"))
        {
            return Forbid();
        }

        var result = await _obraIndex.DeleteAsync(colaboradorId, idObra, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    [HttpPost("convidar")]
    public async Task<IActionResult> Convidar([FromBody] ObraConviteRequestDto? body, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new ObraIndexActionResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraIndexService.CanObraLista(HttpContext, "enviarConvite"))
        {
            return Forbid();
        }

        if (body == null || body.IdObra <= 0)
        {
            return BadRequest(new ObraIndexActionResultDto { Ok = false, ErrorMessage = "Obra inválida." });
        }

        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var result = await _obraIndex.ConvidarAsync(colaboradorId, body, baseUrl, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    /// <summary>Aceita nova=true|1 (ASP.NET [FromQuery] bool rejeita "1").</summary>
    private static bool IsNovaQuery(string? nova) =>
        string.Equals(nova, "1", StringComparison.OrdinalIgnoreCase)
        || string.Equals(nova, "true", StringComparison.OrdinalIgnoreCase);

    [HttpGet("cadastro")]
    public async Task<IActionResult> GetCadastro([FromQuery] string? nova = null, CancellationToken cancellationToken = default)
    {
        if (IsNovaQuery(nova))
        {
            if (!TryColaboradorId(out var colaboradorId))
            {
                return Unauthorized(new { message = "Sessão inválida." });
            }

            int? templateId = ObraSessionHelper.HasObraSelected(HttpContext)
                ? ObraSessionHelper.GetObraId(HttpContext)
                : null;
            // Sem herdar Cidade/UF da sessão — usuário preenche via CEP ou selects.
            var dtoNova = await _cadastro.BuildNovaAsync(colaboradorId, templateId, cancellationToken);
            return Ok(dtoNova);
        }

        if (!TryColaboradorId(out var colabEdit))
            return Unauthorized(new { message = "Sessão inválida." });
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var dto = await _cadastro.GetAsync(obraId, colabEdit, cancellationToken);
        if (dto == null) return NotFound(new { message = "Obra nao encontrada." });
        return Ok(dto);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> PutCadastro(
        [FromBody] ObraCadastroSaveRequestDto? body,
        [FromQuery] string? nova = null,
        CancellationToken cancellationToken = default)
    {
        if (body == null) return BadRequest(new ObraCadastroSaveResultDto { Ok = false, ErrorMessage = "Corpo invalido." });

        // Query ?nova=true|1 (preferido) ou body.Nova (legado).
        var isNova = IsNovaQuery(nova) || body.Nova;
        if (isNova)
        {
            if (!TryColaboradorId(out var colaboradorId))
            {
                return Unauthorized(new ObraCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
            }

            // P3: obra da sessão. P2 (+ sem obra): qualquer vínculo do colaborador como modelo.
            int? templateId = ObraSessionHelper.HasObraSelected(HttpContext)
                ? ObraSessionHelper.GetObraId(HttpContext)
                : null;

            ObraCadastroSaveResultDto created;
            try
            {
                created = await _cadastro.CreateAsync(colaboradorId, templateId, body, cancellationToken);
            }
            catch (Exception ex)
            {
                return BadRequest(new ObraCadastroSaveResultDto
                {
                    Ok = false,
                    ErrorMessage = "Erro ao criar obra: " + (ex.InnerException?.Message ?? ex.Message),
                });
            }

            if (!created.Ok || created.ObraId is not > 0)
            {
                return BadRequest(created);
            }

            try
            {
                var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
                var existingLogin = LoginSessionJson.TryDeserialize(loginDataJson);
                var selected = await _loginObra.SelectObraAsync(
                    colaboradorId,
                    created.ObraId.Value,
                    existingLogin,
                    cancellationToken);
                if (selected.Success && selected.LoginData != null)
                {
                    HttpContext.Session.SetInt32(SessionKeys.ObraId, selected.ObraId);
                    HttpContext.Session.SetString(SessionKeys.ObraNome, selected.ObraNome ?? string.Empty);
                    HttpContext.Session.SetString(SessionKeys.ObraCidadeEstado, selected.ObraCidadeEstado ?? string.Empty);
                    HttpContext.Session.SetInt32(SessionKeys.ObraColaboradorId, selected.ObraColaboradorId);
                    if (LoginSessionJson.TrySerialize(selected.LoginData, out var loginJson))
                    {
                        HttpContext.Session.SetString(SessionKeys.LoginData, loginJson);
                    }
                }
            }
            catch
            {
                // Obra já gravada — não falhar o save se a troca de sessão/histórico falhar.
            }

            return Ok(created);
        }

        if (!TryColaboradorId(out var colabSave))
            return Unauthorized(new ObraCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new ObraCadastroSaveResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        ObraCadastroSaveResultDto result;
        try
        {
            result = await _cadastro.SaveAsync(obraId, colabSave, body, cancellationToken);
        }
        catch (Exception ex)
        {
            return BadRequest(new ObraCadastroSaveResultDto
            {
                Ok = false,
                ErrorMessage = "Erro ao salvar obra: " + (ex.InnerException?.Message ?? ex.Message),
            });
        }
        if (!result.Ok) return BadRequest(result);
        if (!string.IsNullOrWhiteSpace(result.ObraNome))
            HttpContext.Session.SetString(SessionKeys.ObraNome, result.ObraNome);
        return Ok(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
