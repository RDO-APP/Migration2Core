using System.Globalization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

/// <summary>
/// M6 — paridade legado <c>POST /api/obra/ObterObras</c> para Apontador homolog (JWT Bearer).
/// Evita redirect HTML do cookie (causa do spinner infinito no app).
/// </summary>
[ApiController]
[Route("api/obra")]
[EnableCors("MobileJwt")]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public sealed class MobileObraLegacyController : ControllerBase
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");

    private readonly RdoDbContext _context;
    private readonly ILogger<MobileObraLegacyController> _logger;

    public MobileObraLegacyController(RdoDbContext context, ILogger<MobileObraLegacyController> logger)
    {
        _context = context;
        _logger = logger;
    }

    public sealed class ObterObrasBody
    {
        public int IdColaborador { get; set; }
    }

    [HttpPost("ObterObras")]
    public async Task<IActionResult> ObterObras(
        [FromBody] ObterObrasBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        // App manda idColaborador; preferir claim JWT (não confiar só no body).
        if (body?.IdColaborador > 0 && body.IdColaborador != colaboradorId)
        {
            _logger.LogWarning(
                "ObterObras: body idColaborador {BodyId} ≠ JWT {JwtId} — usando JWT",
                body.IdColaborador,
                colaboradorId);
        }

        var rows = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on m.MunIdUf equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            join g in _context.Grupos.AsNoTracking() on oc.OcoIdGrupo equals g.GruIdGrupo into gj
            from g in gj.DefaultIfEmpty()
            join ec in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratante equals ec.EmpIdEmpresa into ecj
            from ec in ecj.DefaultIfEmpty()
            join ed in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratada equals ed.EmpIdEmpresa into edj
            from ed in edj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId
            orderby o.ObrDsObra ?? ""
            select new
            {
                o.ObrIdObra,
                Descricao = o.ObrDsObra ?? "",
                o.ObrDtInicio,
                o.ObrDtPrevisaoFim,
                o.ObrDtFim,
                o.ObrIdDono,
                Cidade = m != null ? m.MunDsMunicipio ?? "" : "",
                UfSigla = uf != null ? uf.UfeDsSigla ?? "" : "",
                GruStContratante = g != null ? g.GruStContratante : (int?)null,
                GruNmNome = g != null ? g.GruNmNome ?? "" : "",
                Contratante = ec != null ? ec.EmpNmFantasia ?? "" : "",
                Contratada = ed != null ? ed.EmpNmFantasia ?? "" : "",
                IdContratante = o.ObrIdEmpresaContratante ?? 0,
                IdContratada = o.ObrIdEmpresaContratada ?? 0,
                IdMunicipio = o.ObrIdMunicipio,
                IdUf = m != null ? m.MunIdUf : 0,
            }).ToListAsync(cancellationToken);

        var hoje = DateTime.Today;
        var lista = rows.Select(r =>
        {
            var progresso = ObraListParity.ProgressoPorcentagem(r.ObrDtInicio, r.ObrDtPrevisaoFim);
            var finalizada = ObraListParity.ObraFinalizada(r.ObrDtFim);
            var cidadeEstado = string.IsNullOrEmpty(r.UfSigla)
                ? r.Cidade
                : $"{r.Cidade}/{r.UfSigla}";
            var dias = Math.Max(0, (hoje - r.ObrDtInicio.Date).Days);

            return new
            {
                idColaborador = colaboradorId,
                idObra = r.ObrIdObra,
                descricao = r.Descricao,
                cidadeEstado,
                idDono = r.ObrIdDono ?? 0,
                idContratante = r.IdContratante,
                idContratada = r.IdContratada,
                descricaoContratante = r.Contratante,
                descricaoContratada = r.Contratada,
                dataInicio = r.ObrDtInicio.ToString("dd/MM/yyyy", PtBr),
                dataConclusao = r.ObrDtFim?.ToString("dd/MM/yyyy", PtBr) ?? "",
                idMunicipio = r.IdMunicipio,
                idUf = r.IdUf,
                obraFinalizada = finalizada,
                qtdHrsSemana = 0,
                qtdHrsSabado = 0,
                qtdHrsDomingo = 0,
                areaTotalObra = 0,
                areaTotalConstruida = 0,
                diasDecorridos = dias,
                classeStatusCss = ObraListParity.ClasseStatusCss(progresso, existeTarefaPendenteAposPrazo: false),
                progressoPorcentagem = progresso,
                colaboradorObj = new
                {
                    idColaborador = 0,
                    idMunicipio = 0,
                    uf = 0,
                    grupo = 0,
                    cargo = 0,
                    idObraColaborador = 0,
                    marcado = false,
                    excluivel = false,
                    editavel = false,
                },
                equipamentoObj = new
                {
                    id = 0,
                    idObra = 0,
                    idObraEquipamento = 0,
                    idTipoEquipamento = 0,
                },
                contratanteContratada = ObraListParity.ContratanteContratadaIcon(r.GruStContratante),
                statusBasicaGratuita = (r.GruNmNome ?? "").Trim(),
                marcado = false,
                listaColaboradores = Array.Empty<object>(),
                listaEquipamentos = Array.Empty<object>(),
                listaColaboradoresRemovidos = Array.Empty<object>(),
                listaEquipamentosRemovidos = Array.Empty<object>(),
            };
        }).ToList();

        return Ok(lista);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
