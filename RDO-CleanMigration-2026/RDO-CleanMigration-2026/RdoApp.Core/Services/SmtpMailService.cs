using System.Net;
using System.Net.Mail;

namespace RdoApp.Core.Services;

/// <summary>Envio SMTP único (Esqueci senha + Convite obra) — chaves <c>Smtp:*</c>.</summary>
public sealed class SmtpMailService
{
    private readonly IConfiguration _configuration;

    public SmtpMailService(IConfiguration configuration)
    {
        _configuration = configuration;
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
}
