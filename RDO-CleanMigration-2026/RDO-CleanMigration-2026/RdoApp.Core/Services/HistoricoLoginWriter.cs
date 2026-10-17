using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;

namespace RdoApp.Core.Services;

public class HistoricoLoginWriter
{
    private readonly RdoDbContext _context;
    private readonly ILogger<HistoricoLoginWriter> _logger;

    public HistoricoLoginWriter(RdoDbContext context, ILogger<HistoricoLoginWriter> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task RecordAsync(
        int colaboradorId,
        string cpf,
        string nome,
        string email,
        int? obraId,
        string? obraNome,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var obraIdSql = obraId.HasValue ? obraId.Value.ToString() : "NULL";
            var obraDsSql = obraNome != null ? $"'{obraNome.Replace("'", "''")}'" : "NULL";

            var insert = $@"
                INSERT INTO historico_login
                (col_id_colaborador, col_nr_cpf, col_nm_colaborador, col_ds_email, obr_id_obra, obr_ds_obra, data_login)
                VALUES (
                    {colaboradorId},
                    '{cpf.Replace("'", "''")}',
                    '{nome.Replace("'", "''")}',
                    '{email.Replace("'", "''")}',
                    {obraIdSql},
                    {obraDsSql},
                    '{DateTime.Now:yyyy-MM-dd HH:mm:ss}'
                )";

            await _context.Database.ExecuteSqlRawAsync(insert, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to insert historico_login for colaborador {ColaboradorId}", colaboradorId);
        }
    }
}
