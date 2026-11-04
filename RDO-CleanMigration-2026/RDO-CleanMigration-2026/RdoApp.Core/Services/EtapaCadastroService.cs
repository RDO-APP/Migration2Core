using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 — cadastro etapa (toolbar ADICIONAR ETAPA). Paridade EtapaModel.Create.</summary>
public class EtapaCadastroService
{
    private readonly RdoDbContext _context;

    public EtapaCadastroService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<EtapaCadastroBlankDto> GetBlankAsync(int obraId, CancellationToken cancellationToken)
    {
        var max = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .Select(e => (int?)e.EtaNrOrderm)
            .MaxAsync(cancellationToken) ?? 0;
        return new EtapaCadastroBlankDto { OrdemSugerida = max + 1 };
    }

    public async Task<EtapaCadastroSaveResultDto> CreateAsync(
        int obraId,
        EtapaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        var titulo = (request.Titulo ?? "").Trim();
        if (titulo.Length == 0)
        {
            return Fail("O Nome deve ser preenchido");
        }

        if (request.Ordem <= 0)
        {
            return Fail("O Nº Ordem deve ser preenchido.");
        }

        var mesmaOrdem = await _context.Etapas.AsNoTracking()
            .AnyAsync(
                e => e.EtaIdObra == obraId && e.EtaNrOrderm == request.Ordem,
                cancellationToken);
        if (mesmaOrdem)
        {
            return Fail("Já existe uma Etapa cadastrada com o mesmo número de ordem. Por favor, verifique!");
        }

        var entity = new Etapa
        {
            EtaDsEtapa = titulo,
            EtaNrOrderm = request.Ordem,
            EtaIdObra = obraId
        };
        _context.Etapas.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);
        return new EtapaCadastroSaveResultDto { Ok = true, Id = entity.EtaIdEtapa };
    }

    private static EtapaCadastroSaveResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };
}
