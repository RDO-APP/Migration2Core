using System.Globalization;
using System.Net;
using System.Net.Mail;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Menu ☰ Obras — listagem/filtros/ações (paridade Obra/index.html).</summary>
public class ObraIndexService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;

    public ObraIndexService(RdoDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<ObraIndexBootstrapDto> BootstrapAsync(
        HttpContext httpContext,
        int colaboradorId,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var empresas = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            where oc.OcoIdColaborador == colaboradorId
            select new { o.ObrIdEmpresaContratante, o.ObrIdEmpresaContratada }
        ).ToListAsync(cancellationToken);

        var empresaIds = empresas
            .SelectMany(e => new[] { e.ObrIdEmpresaContratante, e.ObrIdEmpresaContratada })
            .Where(id => id != null && id > 0)
            .Select(id => id!.Value)
            .Distinct()
            .ToList();

        var empresaLookups = empresaIds.Count == 0
            ? new List<ObraIndexLookupDto>()
            : await _context.Empresas.AsNoTracking()
                .Where(e => empresaIds.Contains(e.EmpIdEmpresa))
                .OrderBy(e => e.EmpNmFantasia)
                .Select(e => new ObraIndexLookupDto { Id = e.EmpIdEmpresa, Nome = e.EmpNmFantasia ?? "" })
                .ToListAsync(cancellationToken);

        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new ObraIndexLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);

        const string route = "/obra/index";
        return new ObraIndexBootstrapDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Empresas = empresaLookups,
            Ufs = ufs,
            Permissions = new ObraIndexPermissionsDto
            {
                ShowVisualizar = PermissionHelper.HasPermission(httpContext, "visualizarRegistro", route),
                ShowEnviarConvite = PermissionHelper.HasPermission(httpContext, "enviarConvite", route),
                ShowCopiar = PermissionHelper.HasPermission(httpContext, "copiarObra", route),
                ShowEditar = PermissionHelper.HasPermission(httpContext, "editar", route),
                ShowDeletar = PermissionHelper.HasPermission(httpContext, "deletar", route),
                ShowCriarNovo = PermissionHelper.HasPermission(httpContext, "criarNovo", route),
            },
        };
    }

    public async Task<IReadOnlyList<ObraIndexLookupDto>> MunicipiosByUfAsync(
        int idUf,
        CancellationToken cancellationToken)
    {
        if (idUf <= 0)
        {
            return [];
        }

        return await _context.Municipios.AsNoTracking()
            .Where(m => m.MunIdUf == idUf)
            .OrderBy(m => m.MunDsMunicipio)
            .Select(m => new ObraIndexLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
            .ToListAsync(cancellationToken);
    }

    public async Task<ObraIndexListResponseDto> ListAsync(
        int colaboradorId,
        ObraIndexFilterDto filter,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var q =
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on (m != null ? m.MunIdUf : 0) equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            join ec in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratante equals ec.EmpIdEmpresa into ecj
            from ec in ecj.DefaultIfEmpty()
            join ed in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratada equals ed.EmpIdEmpresa into edj
            from ed in edj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId
            select new
            {
                o.ObrIdObra,
                Descricao = o.ObrDsObra ?? "",
                o.ObrDtInicio,
                o.ObrDtPrevisaoFim,
                o.ObrDtFim,
                o.ObrIdEmpresaContratante,
                o.ObrIdMunicipio,
                MunIdUf = m != null ? m.MunIdUf : 0,
                Cidade = m != null ? m.MunDsMunicipio ?? "" : "",
                Uf = uf != null ? uf.UfeDsSigla ?? "" : "",
                Contratante = ec != null ? ec.EmpNmFantasia ?? "" : "",
                Contratada = ed != null ? ed.EmpNmFantasia ?? "" : "",
            };

        var filtroNome = (filter.Descricao ?? "").Trim();
        if (filtroNome.Length > 0)
        {
            var lower = filtroNome.ToLowerInvariant();
            q = q.Where(x => x.Descricao.ToLower().Contains(lower));
        }

        if (filter.IdContratante > 0)
        {
            q = q.Where(x => x.ObrIdEmpresaContratante == filter.IdContratante);
        }

        if (filter.IdUf > 0)
        {
            q = q.Where(x => x.MunIdUf == filter.IdUf);
        }

        if (filter.IdMunicipio > 0)
        {
            q = q.Where(x => x.ObrIdMunicipio == filter.IdMunicipio);
        }

        if (filter.StatusObra == 1)
        {
            q = q.Where(x => x.ObrDtFim == null || x.ObrDtFim == DateTime.MinValue);
        }
        else if (filter.StatusObra == 2)
        {
            q = q.Where(x => x.ObrDtFim != null && x.ObrDtFim != DateTime.MinValue);
        }

        if (TryParseDate(filter.DataInicioDe, out var dataDe))
        {
            q = q.Where(x => x.ObrDtInicio.Date == dataDe);
        }

        // Prod: "Data Final" filtra obr_dt_previsao_fim (não obr_dt_fim).
        if (TryParseDate(filter.DataInicioAte, out var dataAte))
        {
            q = q.Where(x => x.ObrDtPrevisaoFim != null && x.ObrDtPrevisaoFim.Value.Date == dataAte);
        }

        var rows = await q.OrderBy(x => x.Descricao).ToListAsync(cancellationToken);
        var hoje = DateTime.Now.Date;
        var items = rows.Select(r =>
        {
            var cidadeEstado = string.IsNullOrEmpty(r.Uf) ? r.Cidade : $"{r.Cidade}/{r.Uf}";
            var fim = r.ObrDtFim ?? DateTime.MinValue;
            var dias = fim == DateTime.MinValue
                ? (hoje - r.ObrDtInicio.Date).Days
                : (fim.Date - r.ObrDtInicio.Date).Days;
            return new ObraIndexItemDto
            {
                IdObra = r.ObrIdObra,
                Descricao = r.Descricao,
                DescricaoContratante = r.Contratante,
                DescricaoContratada = r.Contratada,
                DataInicio = r.ObrDtInicio.ToString("dd/MM/yyyy"),
                DataConclusao = r.ObrDtFim == null || r.ObrDtFim == DateTime.MinValue
                    ? ""
                    : r.ObrDtFim.Value.ToString("dd/MM/yyyy"),
                CidadeEstado = cidadeEstado,
                DiasDecorridos = dias,
            };
        }).ToList();

        return new ObraIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = items,
        };
    }

    public async Task<ObraIndexActionResultDto> DeleteAsync(
        int colaboradorId,
        int idObra,
        CancellationToken cancellationToken)
    {
        var vinculado = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObra, cancellationToken);
        if (!vinculado)
        {
            return Fail("Obra não encontrada ou sem permissão.");
        }

        var entity = await _context.Obras.FirstOrDefaultAsync(o => o.ObrIdObra == idObra, cancellationToken);
        if (entity == null)
        {
            return Fail("Obra não encontrada.");
        }

        _context.Obras.Remove(entity);
        try
        {
            await _context.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            return Fail("Não é possível excluir esta obra. Existem registros dependentes.");
        }

        return new ObraIndexActionResultDto { Ok = true };
    }

    public async Task<ObraIndexActionResultDto> ConvidarAsync(
        int colaboradorId,
        ObraConviteRequestDto request,
        string publicBaseUrl,
        CancellationToken cancellationToken)
    {
        var email = (request.EmailConvidada ?? "").Trim();
        if (email.Length == 0)
        {
            return Fail("O Email do Convidado deve ser preenchido.");
        }

        if (!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
        {
            return Fail("O Email é inválido.");
        }

        var vinculado = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == request.IdObra, cancellationToken);
        if (!vinculado)
        {
            return Fail("Obra não encontrada ou sem permissão.");
        }

        var obra = await _context.Obras.FirstOrDefaultAsync(o => o.ObrIdObra == request.IdObra, cancellationToken);
        if (obra == null)
        {
            return Fail("Obra não encontrada.");
        }

        if (obra.ObrIdEmpresaContratada != null && obra.ObrIdEmpresaContratante != null)
        {
            return Fail("Já existe empresa contratante e contratada para essa obra.");
        }

        string papel;
        if (obra.ObrIdEmpresaContratada != null && obra.ObrIdEmpresaContratante == null)
        {
            papel = "CONTRATANTE";
        }
        else if (obra.ObrIdEmpresaContratante != null && obra.ObrIdEmpresaContratada == null)
        {
            papel = "CONTRATADA";
        }
        else
        {
            papel = "CONVIDADA";
        }

        obra.ObrCdConvite = Guid.NewGuid().ToString("N");
        await _context.SaveChangesAsync(cancellationToken);

        var baseUrl = (publicBaseUrl ?? "").TrimEnd('/');
        if (baseUrl.Length == 0)
        {
            baseUrl = (_configuration["App:PublicBaseUrl"] ?? "https://homolog.sistema.rdoapp.com.br").TrimEnd('/');
        }

        var link = $"{baseUrl}/convidada?o={obra.ObrCdConvite}";
        var html =
            $"<p>Prezado Usuario(a):<br/><br/>Este é um convite para ser {papel} na obra <strong>{System.Net.WebUtility.HtmlEncode(obra.ObrDsObra)}</strong>.<br/>Para aceitar acesse o link: {link}</p><p>Atenciosamente,</p>";

        try
        {
            await EnviarEmailAsync(email, "Convite para o RDO App", html, cancellationToken);
        }
        catch (Exception ex)
        {
            return Fail($"Não foi possível enviar o e-mail: {ex.Message}");
        }

        return new ObraIndexActionResultDto { Ok = true };
    }

    private async Task EnviarEmailAsync(string to, string subject, string htmlBody, CancellationToken cancellationToken)
    {
        var host = _configuration["Smtp:Host"];
        if (string.IsNullOrWhiteSpace(host))
        {
            throw new InvalidOperationException("Smtp:Host não configurado.");
        }

        var port = _configuration.GetValue("Smtp:Port", 587);
        var enableSsl = _configuration.GetValue("Smtp:EnableSsl", true);
        var fromEmail = _configuration["Smtp:FromEmail"] ?? _configuration["Smtp:User"] ?? "noreply@rdoapp.com.br";
        var fromName = _configuration["Smtp:FromName"] ?? "RDO App";
        var user = _configuration["Smtp:User"];
        var password = _configuration["Smtp:Password"];

        using var client = new SmtpClient(host, port)
        {
            EnableSsl = enableSsl,
            DeliveryMethod = SmtpDeliveryMethod.Network,
        };
        if (!string.IsNullOrWhiteSpace(user))
        {
            client.Credentials = new NetworkCredential(user, password);
        }

        using var message = new MailMessage
        {
            From = new MailAddress(fromEmail, fromName),
            Subject = subject,
            Body = htmlBody,
            IsBodyHtml = true,
        };
        message.To.Add(to);
        await client.SendMailAsync(message, cancellationToken);
    }

    private static bool TryParseDate(string? raw, out DateTime date)
    {
        date = default;
        var t = (raw ?? "").Trim();
        if (t.Length == 0)
        {
            return false;
        }

        return DateTime.TryParseExact(t, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date)
            || DateTime.TryParse(t, PtBr, DateTimeStyles.None, out date);
    }

    private static ObraIndexActionResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };
}
