using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[AllowAnonymous]
[ApiController]
[Route("api/bff/convidada")]
public sealed class BffConvidadaController : ControllerBase
{
    private readonly ConvidadaAceiteService _service;

    public BffConvidadaController(ConvidadaAceiteService service)
    {
        _service = service;
    }

    [HttpGet("bootstrap")]
    public async Task<ActionResult<ConvidadaBootstrapDto>> Bootstrap(
        [FromQuery] string? o,
        CancellationToken cancellationToken)
    {
        var dto = await _service.BootstrapAsync(o, cancellationToken);
        if (!dto.Ok)
        {
            return BadRequest(dto);
        }

        return Ok(dto);
    }

    [HttpPost("municipios")]
    public async Task<ActionResult<IReadOnlyList<ConvidadaLookupDto>>> Municipios(
        [FromBody] ConvidadaMunicipiosRequestDto request,
        CancellationToken cancellationToken)
    {
        var list = await _service.MunicipiosAsync(request.IdUf, cancellationToken);
        return Ok(list);
    }

    [HttpPost("empresa-cnpj")]
    public async Task<ActionResult<ConvidadaEmpresaHintDto>> EmpresaCnpj(
        [FromBody] ConvidadaCnpjRequestDto request,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.EmpresaPorCnpjAsync(request.Cnpj, cancellationToken));
    }

    [HttpPost("colaborador-cpf")]
    public async Task<ActionResult<ConvidadaColaboradorHintDto>> ColaboradorCpf(
        [FromBody] ConvidadaCpfRequestDto request,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.ColaboradorPorCpfAsync(request.Cpf, cancellationToken));
    }

    [HttpPost("acessar")]
    public async Task<ActionResult<ConvidadaAcessarResultDto>> Acessar(
        [FromBody] ConvidadaAcessarRequestDto request,
        CancellationToken cancellationToken)
    {
        var (result, colaborador) = await _service.AcessarAsync(request, cancellationToken);
        if (!result.Ok || colaborador == null)
        {
            return BadRequest(result);
        }

        await SignInConvidadaAsync(colaborador);
        return Ok(result);
    }

    private async Task SignInConvidadaAsync(Colaborador colaborador)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, colaborador.ColIdColaborador.ToString()),
            new(ClaimTypes.Name, colaborador.ColNmColaborador ?? ""),
            new("cpf", colaborador.ColNrCpf ?? ""),
            new("email", colaborador.ColDsEmail ?? ""),
            new("isAdmin", (colaborador.ColStAdmin == true).ToString()),
        };

        var identity = new ClaimsIdentity(claims, "Cookies");
        var principal = new ClaimsPrincipal(identity);
        var props = new AuthenticationProperties
        {
            IsPersistent = false,
            ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8),
        };

        await HttpContext.SignInAsync("Cookies", principal, props);

        var loginVm = new LoginViewModel
        {
            Routes = new List<RouteViewModel>
            {
                new RouteViewModel
                {
                    Name = "Escolher Obra",
                    Path = "/obra/escolher",
                    Permissions = new List<string> { "visualizar" },
                },
            },
            Menu = new MenuViewModel(),
            Usuario = new UsuarioViewModel
            {
                Id = colaborador.ColIdColaborador,
                NomeUsuario = colaborador.ColNmColaborador,
                Email = colaborador.ColDsEmail,
                Senha = string.Empty,
            },
        };

        HttpContext.Session.SetInt32("ColaboradorId", colaborador.ColIdColaborador);
        HttpContext.Session.SetString(SessionKeys.LoginData, LoginSessionJson.Serialize(loginVm));
    }
}
