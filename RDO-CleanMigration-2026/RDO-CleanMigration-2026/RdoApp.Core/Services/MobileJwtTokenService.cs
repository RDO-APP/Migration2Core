using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Services;

/// <summary>M6 Fase 1.2 — issues JWT with the same claims as cookie login.</summary>
public sealed class MobileJwtTokenService
{
    private readonly JwtOptions _options;

    public MobileJwtTokenService(IOptions<JwtOptions> options)
    {
        _options = options.Value;
    }

    public (string AccessToken, int ExpiresInSeconds) CreateToken(Colaborador colaborador) =>
        CreateToken(colaborador, obraId: null, obraColaboradorId: null, grupoId: null);

    /// <summary>M6 Bearer — opcionalmente embute contexto da obra (pós-LoginObra).</summary>
    public (string AccessToken, int ExpiresInSeconds) CreateToken(
        Colaborador colaborador,
        int? obraId,
        int? obraColaboradorId,
        int? grupoId)
    {
        var expiresInSeconds = Math.Max(60, _options.ExpiryMinutes * 60);
        var expires = DateTime.UtcNow.AddSeconds(expiresInSeconds);

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, colaborador.ColIdColaborador.ToString()),
            new(ClaimTypes.Name, colaborador.ColNmColaborador ?? ""),
            new("cpf", colaborador.ColNrCpf ?? ""),
            new("email", colaborador.ColDsEmail ?? ""),
            new("isAdmin", (colaborador.ColStAdmin == true).ToString()),
        };

        if (obraId is > 0)
        {
            claims.Add(new Claim("obraId", obraId.Value.ToString()));
        }

        if (obraColaboradorId is > 0)
        {
            claims.Add(new Claim("obraColaboradorId", obraColaboradorId.Value.ToString()));
        }

        if (grupoId is > 0)
        {
            claims.Add(new Claim("grupoId", grupoId.Value.ToString()));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SigningKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expires,
            signingCredentials: credentials);

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        return (accessToken, expiresInSeconds);
    }
}
