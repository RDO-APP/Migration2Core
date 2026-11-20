using System.Net;
using System.Net.Mail;
using System.Text;

namespace RdoApp.Core.Services;

/// <summary>Envio SMTP único (Esqueci senha + Convite obra) — chaves <c>Smtp:*</c>.</summary>
public sealed class SmtpMailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SmtpMailService> _logger;

    public SmtpMailService(IConfiguration configuration, ILogger<SmtpMailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendAsync(string to, string subject, string htmlBody, CancellationToken cancellationToken = default)
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

        // Ordem importa no SmtpClient: UseDefaultCredentials=false antes de Credentials.
        using var client = new SmtpClient(host, port)
        {
            DeliveryMethod = SmtpDeliveryMethod.Network,
            EnableSsl = enableSsl,
            UseDefaultCredentials = false,
        };
        if (!string.IsNullOrWhiteSpace(user))
        {
            client.Credentials = new NetworkCredential(user, password ?? "");
        }

        using var message = new MailMessage
        {
            From = new MailAddress(fromEmail, fromName),
            Subject = subject,
            Body = htmlBody,
            IsBodyHtml = true,
        };
        message.To.Add(to);
        try
        {
            await client.SendMailAsync(message, cancellationToken);
        }
        catch (SmtpException ex)
        {
            var detail = FormatSmtpFailure(ex);
            _logger.LogError(ex, "SMTP falhou {Host}:{Port} Ssl={Ssl} To={To}", host, port, enableSsl, to);
            throw new InvalidOperationException($"SMTP {host}:{port} Ssl={enableSsl}: {detail}", ex);
        }
    }

    private static string FormatSmtpFailure(SmtpException ex)
    {
        var sb = new StringBuilder();
        sb.Append("Status=").Append(ex.StatusCode);
        for (Exception? e = ex; e != null; e = e.InnerException)
        {
            sb.Append(" | ").Append(e.GetType().Name).Append(": ").Append(e.Message);
        }

        return sb.ToString();
    }
}
