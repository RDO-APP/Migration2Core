using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

public sealed class LoginObraResult
{
    public bool Success { get; init; }
    public string? ErrorMessage { get; init; }
    public LoginViewModel? LoginData { get; init; }
    public int ObraId { get; init; }
    public string? ObraNome { get; init; }
    public int ObraColaboradorId { get; init; }

    public static LoginObraResult Fail(string message) => new() { Success = false, ErrorMessage = message };
}

public class LoginObraService
{
    private readonly RdoDbContext _context;
    private readonly RbacRouteService _rbac;
    private readonly HistoricoLoginWriter _historico;
    private readonly IConfiguration _configuration;
    private readonly ILogger<LoginObraService> _logger;

    public LoginObraService(
        RdoDbContext context,
        RbacRouteService rbac,
        HistoricoLoginWriter historico,
        IConfiguration configuration,
        ILogger<LoginObraService> logger)
    {
        _context = context;
        _rbac = rbac;
        _historico = historico;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<LoginObraResult> SelectObraAsync(
        int colaboradorId,
        int idObra,
        LoginViewModel? existingLogin,
        CancellationToken cancellationToken = default)
    {
        var assignment = await (
            from oc in _context.ObraColaboradores
            join o in _context.Obras on oc.OcoIdObra equals o.ObrIdObra
            join c in _context.Colaboradores on oc.OcoIdColaborador equals c.ColIdColaborador
            join g in _context.Grupos on oc.OcoIdGrupo equals g.GruIdGrupo
            where oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObra
            select new { oc, o, c, g }
        ).FirstOrDefaultAsync(cancellationToken);

        if (assignment == null)
        {
            _logger.LogWarning("Obra {ObraId} not assigned to colaborador {ColaboradorId}", idObra, colaboradorId);
            return LoginObraResult.Fail("Você não tem permissão para acessar esta obra.");
        }

        if (!await IsLicenseActiveAsync(assignment.o.ObrIdDono, cancellationToken))
        {
            return LoginObraResult.Fail("Não foi possível acessar esta obra. Verifique a assinatura da empresa.");
        }

        var grupoNome = assignment.g.GruNmNome ?? string.Empty;
        var grupoLower = grupoNome.ToLowerInvariant();

        var loginData = existingLogin ?? new LoginViewModel();
        loginData.Routes = await _rbac.GetRoutesForGroupAsync(assignment.oc.OcoIdGrupo, cancellationToken);
        loginData.Menu = await _rbac.GetMenuForGroupAsync(assignment.oc.OcoIdGrupo, cancellationToken);
        loginData.Usuario = new UsuarioViewModel
        {
            Email = assignment.c.ColDsEmail,
            Id = assignment.c.ColIdColaborador,
            Senha = TryDecryptColaboradorSenha(assignment.c.ColDsSenha),
            NomeUsuario = assignment.c.ColNmColaborador,
            IdGrupo = assignment.oc.OcoIdGrupo
        };
        loginData.ObraColaborador = new ObraColaboradorViewModel
        {
            IdObraColaborador = assignment.oc.OcoIdObraColaborador,
            NomeObra = assignment.o.ObrDsObra,
            NomeColaborador = assignment.c.ColNmColaborador,
            IdObra = assignment.oc.OcoIdObra,
            IdColaborador = assignment.oc.OcoIdColaborador,
            IdGrupo = assignment.oc.OcoIdGrupo,
            IdCargo = assignment.oc.OcoIdCargo,
            ContratanteContratada = grupoLower.Contains("contratante") ? "t" : "d",
            DataContratacao = assignment.oc.OcoDtContratacao ?? DateTime.MinValue,
            TipoLicencaColaboradorGrupo = grupoLower.Contains("basica") ? "basica" : "gratuita",
            IdLicenca = assignment.g.GruIdLicenca ?? int.MinValue
        };

        var fim = assignment.o.ObrDtFim;
        loginData.Obra = new ObraViewModel
        {
            IdObra = assignment.o.ObrIdObra,
            Descricao = assignment.o.ObrDsObra,
            idDono = assignment.o.ObrIdDono ?? 0,
            idContratante = assignment.o.ObrIdEmpresaContratante ?? 0,
            idContratada = assignment.o.ObrIdEmpresaContratada ?? 0,
            DataFim = fim?.ToString() ?? string.Empty,
            ObraFinalizada = fim.HasValue && fim.Value.Date != DateTime.MinValue.Date,
            idColaborador = assignment.o.ObrIdColaborador ?? 0
        };

        await _historico.RecordAsync(
            assignment.c.ColIdColaborador,
            assignment.c.ColNrCpf,
            assignment.c.ColNmColaborador,
            assignment.c.ColDsEmail ?? string.Empty,
            assignment.o.ObrIdObra,
            assignment.o.ObrDsObra,
            cancellationToken);

        return new LoginObraResult
        {
            Success = true,
            LoginData = loginData,
            ObraId = assignment.o.ObrIdObra,
            ObraNome = assignment.o.ObrDsObra,
            ObraColaboradorId = assignment.oc.OcoIdObraColaborador
        };
    }

    private async Task<bool> IsLicenseActiveAsync(int? idDono, CancellationToken cancellationToken)
    {
        if (_configuration.GetValue("Migration:DisableAssinaturaCheck", true))
        {
            return true;
        }

        if (!idDono.HasValue || idDono.Value <= 0)
        {
            return false;
        }

        var token = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpIdEmpresa == idDono.Value)
            .Select(e => e.EmpIdToken)
            .FirstOrDefaultAsync(cancellationToken);

        return !string.IsNullOrWhiteSpace(token);
    }

    private static string TryDecryptColaboradorSenha(string? stored)
    {
        if (string.IsNullOrWhiteSpace(stored))
        {
            return string.Empty;
        }

        try
        {
            return Seguranca.DecryptTripleDES(stored);
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }
}
