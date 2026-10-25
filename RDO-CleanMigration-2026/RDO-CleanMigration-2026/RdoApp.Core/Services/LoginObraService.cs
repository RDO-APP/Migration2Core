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
    public string? ObraCidadeEstado { get; init; }
    public int ObraColaboradorId { get; init; }

    public static LoginObraResult Fail(string message) => new() { Success = false, ErrorMessage = message };
}

public class LoginObraService
{
    /// <summary>Flat row from join — COALESCE in SQL avoids DBNull on legacy nullable columns.</summary>
    private sealed class ObraSelectionRow
    {
        public int OcoIdObraColaborador { get; init; }
        public int OcoIdObra { get; init; }
        public int OcoIdColaborador { get; init; }
        public int OcoIdGrupo { get; init; }
        public int OcoIdCargo { get; init; }
        public DateTime? OcoDtContratacao { get; init; }
        public int ObrIdObra { get; init; }
        public string ObrDsObra { get; init; } = string.Empty;
        public int? ObrIdDono { get; init; }
        public int? ObrIdEmpresaContratante { get; init; }
        public int? ObrIdEmpresaContratada { get; init; }
        public DateTime? ObrDtFim { get; init; }
        public int? ObrIdColaborador { get; init; }
        public int ColIdColaborador { get; init; }
        public string ColNmColaborador { get; init; } = string.Empty;
        public string? ColDsEmail { get; init; }
        public string ColDsSenha { get; init; } = string.Empty;
        public string ColNrCpf { get; init; } = string.Empty;
        public string GruNmNome { get; init; } = string.Empty;
        public int? GruIdLicenca { get; init; }
        public string Cidade { get; init; } = string.Empty;
        public string UfSigla { get; init; } = string.Empty;
    }

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
        var row = await (
            from oc in _context.ObraColaboradores
            join o in _context.Obras on oc.OcoIdObra equals o.ObrIdObra
            join c in _context.Colaboradores on oc.OcoIdColaborador equals c.ColIdColaborador
            join g in _context.Grupos on oc.OcoIdGrupo equals g.GruIdGrupo
            join m in _context.Municipios on o.ObrIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs on m.MunIdUf equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObra
            select new ObraSelectionRow
            {
                OcoIdObraColaborador = oc.OcoIdObraColaborador,
                OcoIdObra = oc.OcoIdObra,
                OcoIdColaborador = oc.OcoIdColaborador,
                OcoIdGrupo = oc.OcoIdGrupo,
                OcoIdCargo = oc.OcoIdCargo,
                OcoDtContratacao = oc.OcoDtContratacao,
                ObrIdObra = o.ObrIdObra,
                ObrDsObra = o.ObrDsObra ?? string.Empty,
                ObrIdDono = o.ObrIdDono,
                ObrIdEmpresaContratante = o.ObrIdEmpresaContratante,
                ObrIdEmpresaContratada = o.ObrIdEmpresaContratada,
                ObrDtFim = o.ObrDtFim,
                ObrIdColaborador = o.ObrIdColaborador,
                ColIdColaborador = c.ColIdColaborador,
                ColNmColaborador = c.ColNmColaborador ?? string.Empty,
                ColDsEmail = c.ColDsEmail,
                ColDsSenha = c.ColDsSenha ?? string.Empty,
                ColNrCpf = c.ColNrCpf ?? string.Empty,
                GruNmNome = g.GruNmNome ?? string.Empty,
                GruIdLicenca = g.GruIdLicenca,
                Cidade = m != null ? m.MunDsMunicipio ?? string.Empty : string.Empty,
                UfSigla = uf != null ? uf.UfeDsSigla ?? string.Empty : string.Empty,
            }
        ).FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            _logger.LogWarning("Obra {ObraId} not assigned to colaborador {ColaboradorId}", idObra, colaboradorId);
            return LoginObraResult.Fail("Você não tem permissão para acessar esta obra.");
        }

        if (!await IsLicenseActiveAsync(row.ObrIdDono, cancellationToken))
        {
            return LoginObraResult.Fail("Não foi possível acessar esta obra. Verifique a assinatura da empresa.");
        }

        var grupoLower = row.GruNmNome.ToLowerInvariant();

        var loginData = existingLogin ?? new LoginViewModel();
        try
        {
            loginData.Routes = await _rbac.GetRoutesForGroupAsync(row.OcoIdGrupo, cancellationToken);
            loginData.Menu = await _rbac.GetMenuForGroupAsync(row.OcoIdGrupo, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "RBAC load failed for grupo {GrupoId}; keeping default routes/menu", row.OcoIdGrupo);
            loginData.Routes ??= new List<RouteViewModel>();
            loginData.Menu ??= new MenuViewModel();
        }
        loginData.Usuario = new UsuarioViewModel
        {
            Email = row.ColDsEmail,
            Id = row.ColIdColaborador,
            Senha = TryDecryptColaboradorSenha(row.ColDsSenha),
            NomeUsuario = row.ColNmColaborador,
            IdGrupo = row.OcoIdGrupo
        };
        loginData.ObraColaborador = new ObraColaboradorViewModel
        {
            IdObraColaborador = row.OcoIdObraColaborador,
            NomeObra = row.ObrDsObra,
            NomeColaborador = row.ColNmColaborador,
            IdObra = row.OcoIdObra,
            IdColaborador = row.OcoIdColaborador,
            IdGrupo = row.OcoIdGrupo,
            IdCargo = row.OcoIdCargo,
            ContratanteContratada = grupoLower.Contains("contratante") ? "t" : "d",
            DataContratacao = row.OcoDtContratacao ?? DateTime.MinValue,
            TipoLicencaColaboradorGrupo = grupoLower.Contains("basica") ? "basica" : "gratuita",
            IdLicenca = row.GruIdLicenca ?? int.MinValue
        };

        var fim = row.ObrDtFim;
        loginData.Obra = new ObraViewModel
        {
            IdObra = row.ObrIdObra,
            Descricao = row.ObrDsObra,
            idDono = row.ObrIdDono ?? 0,
            idContratante = row.ObrIdEmpresaContratante ?? 0,
            idContratada = row.ObrIdEmpresaContratada ?? 0,
            DataFim = fim?.ToString() ?? string.Empty,
            ObraFinalizada = fim.HasValue && fim.Value.Date != DateTime.MinValue.Date,
            idColaborador = row.ObrIdColaborador ?? 0
        };

        await _historico.RecordAsync(
            row.ColIdColaborador,
            row.ColNrCpf,
            row.ColNmColaborador,
            row.ColDsEmail ?? string.Empty,
            row.ObrIdObra,
            row.ObrDsObra,
            cancellationToken);

        var cidadeEstado = string.IsNullOrEmpty(row.UfSigla)
            ? row.Cidade
            : $"{row.Cidade}/{row.UfSigla}";

        return new LoginObraResult
        {
            Success = true,
            LoginData = loginData,
            ObraId = row.ObrIdObra,
            ObraNome = row.ObrDsObra,
            ObraCidadeEstado = cidadeEstado,
            ObraColaboradorId = row.OcoIdObraColaborador
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
