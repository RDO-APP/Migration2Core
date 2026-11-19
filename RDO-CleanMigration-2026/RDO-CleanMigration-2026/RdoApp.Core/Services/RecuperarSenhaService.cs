using System.Net;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Utils;

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
    private readonly SmtpMailService _mail;
    private readonly ILogger<RecuperarSenhaService> _logger;

    public RecuperarSenhaService(
        RdoDbContext context,
        SmtpMailService mail,
        ILogger<RecuperarSenhaService> logger)
    {
        _context = context;
        _mail = mail;
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
            await _mail.SendAsync(email, "RDO App - Recuperar Senha", html, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SMTP failed for password recovery");
            return RecuperarSenhaResult.Fail(
                "Não foi possível enviar o e-mail. Verifique SMTP em homolog ou contate o suporte.");
        }

        return RecuperarSenhaResult.Ok("Enviamos instruções para o e-mail cadastrado.");
    }
}
