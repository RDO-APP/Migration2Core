using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Utils;
using System.Net;
using System.Net.Mail;

namespace RdoApp.Core.Services;

public sealed class RecuperarSenhaResult
{
    public bool Success { get; init; }
    public string Message { get; init; } = "";

    public static RecuperarSenhaResult Ok(string message) => new() { Success = true, Message = message };
    public static RecuperarSenhaResult Fail(string message) => new() { Success = false, Message = message };
}

/// <summary>Paridade prod ColaboradorModel.RecuperarSenha (e-mail com senha descriptografada).</summary>
public class RecuperarSenhaService
{
    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<RecuperarSenhaService> _logger;

    public RecuperarSenhaService(
        RdoDbContext context,
        IConfiguration configuration,
        ILogger<RecuperarSenhaService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<RecuperarSenhaResult> RecuperarAsync(string email, string cpf, CancellationToken cancellationToken = default)
    {
        email = (email ?? "").Trim();
        cpf = (cpf ?? "").Replace(".", "").Replace("-", "").Trim();

        if (string.IsNullOrEmpty(email))
        {
            return RecuperarSenhaResult.Fail("E-mail cadastrado: preenchimento obrigatório.");
        }

        if (string.IsNullOrEmpty(cpf) || cpf == "00000000000")
        {
            return RecuperarSenhaResult.Fail("CPF: preenchimento obrigatório.");
        }

        var colaborador = await _context.Colaboradores.AsNoTracking()
            .FirstOrDefaultAsync(
                c => c.ColDsEmail == email && c.ColNrCpf == cpf,
                cancellationToken);

        if (colaborador == null)
        {
            return RecuperarSenhaResult.Fail("CPF e/ou e-mail inválidos.");
        }

        string senha;
        try
        {
            senha = Seguranca.DecryptTripleDES(colaborador.ColDsSenha ?? string.Empty);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Decrypt password failed for colaborador {Id}", colaborador.ColIdColaborador);
            return RecuperarSenhaResult.Fail("Não foi possível recuperar a senha. Contate o suporte.");
        }

        var nome = colaborador.ColNmColaborador ?? "Usuário";
        var html = $"""
            <p>Prezado(a) usuário(a) <strong>{WebUtility.HtmlEncode(nome)}</strong>,</p>
            <p>Sua senha atual é <strong>{WebUtility.HtmlEncode(senha)}</strong></p>
            <p>Caso não tenha feito essa solicitação, escreva para
            <a href="mailto:suporte@rdoapp.com.br">suporte@rdoapp.com.br</a> com o título "NÃO SOLICITEI SENHA".</p>
            <p>Atenciosamente,</p>
            """;

        try
        {
            await EnviarEmailAsync(email, "RDO App - Recuperar Senha", html, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SMTP failed for password recovery");
            return RecuperarSenhaResult.Fail(
                "Não foi possível enviar o e-mail. Verifique SMTP em homolog ou contate o suporte.");
        }

        return RecuperarSenhaResult.Ok("Enviamos instruções para o e-mail cadastrado.");
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
}
