namespace RdoApp.Core.Infrastructure;

/// <summary>M6 Fase 1.2 — JWT options for mobile Apontador (config section "Jwt").</summary>
public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; set; } = "";

    public string Audience { get; set; } = "";

    /// <summary>HMAC signing key — set a strong secret on EC2 Staging (do not use placeholder in prod).</summary>
    public string SigningKey { get; set; } = "";

    /// <summary>
    /// Access token lifetime in minutes (default 480 = 8h).
    /// M6 1.4: sem refresh token — cliente re-login em 401/expiry
    /// (ver docs/migracao/m6-1.4-seguranca-jwt.md).
    /// </summary>
    public int ExpiryMinutes { get; set; } = 480;
}
