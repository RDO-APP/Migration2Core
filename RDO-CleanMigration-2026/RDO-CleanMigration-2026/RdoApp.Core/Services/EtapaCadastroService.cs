using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 — listagem/cadastro etapa (menu ☰ + toolbar). Paridade EtapaModel.</summary>
public class EtapaCadastroService
{
    private readonly RdoDbContext _context;

    public EtapaCadastroService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<EtapaListResponseDto> ListAsync(
        int obraId,
        string? obraNome,
        string? titulo,
        CancellationToken cancellationToken)
    {
        var q = _context.Etapas.AsNoTracking().Where(e => e.EtaIdObra == obraId);
        var filtro = (titulo ?? "").Trim();
        if (filtro.Length > 0)
        {
            var lower = filtro.ToLowerInvariant();
            q = q.Where(e => e.EtaDsEtapa != null && e.EtaDsEtapa.ToLower().Contains(lower));
        }

        var items = await q
            .OrderBy(e => e.EtaNrOrderm)
            .Select(e => new EtapaListItemDto
            {
                Id = e.EtaIdEtapa,
                Titulo = e.EtaDsEtapa ?? "",
                Ordem = e.EtaNrOrderm
            })
            .ToListAsync(cancellationToken);

        return new EtapaListResponseDto
        {
            ObraNome = obraNome ?? "",
            Items = items
        };
    }

    public async Task<EtapaCadastroBlankDto> GetBlankAsync(int obraId, CancellationToken cancellationToken)
    {
        var max = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .Select(e => (int?)e.EtaNrOrderm)
            .MaxAsync(cancellationToken) ?? 0;
        return new EtapaCadastroBlankDto { OrdemSugerida = max + 1 };
    }

    public async Task<EtapaCadastroBlankDto?> GetForEditAsync(
        int obraId,
        int id,
        CancellationToken cancellationToken)
    {
        var e = await _context.Etapas.AsNoTracking()
            .FirstOrDefaultAsync(x => x.EtaIdEtapa == id && x.EtaIdObra == obraId, cancellationToken);
        if (e == null)
        {
            return null;
        }

        return new EtapaCadastroBlankDto
        {
            Id = e.EtaIdEtapa,
            Titulo = e.EtaDsEtapa,
            OrdemSugerida = e.EtaNrOrderm
        };
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

    public async Task<EtapaCadastroSaveResultDto> UpdateAsync(
        int obraId,
        int id,
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

        var entity = await _context.Etapas
            .FirstOrDefaultAsync(e => e.EtaIdEtapa == id && e.EtaIdObra == obraId, cancellationToken);
        if (entity == null)
        {
            return Fail("Etapa não encontrada.");
        }

        var mesmaOrdem = await _context.Etapas.AsNoTracking()
            .AnyAsync(
                e => e.EtaIdObra == obraId && e.EtaNrOrderm == request.Ordem && e.EtaIdEtapa != id,
                cancellationToken);
        if (mesmaOrdem)
        {
            return Fail("Já existe uma Etapa cadastrada com o mesmo número de ordem. Por favor, verifique!");
        }

        entity.EtaDsEtapa = titulo;
        entity.EtaNrOrderm = request.Ordem;
        await _context.SaveChangesAsync(cancellationToken);
        return new EtapaCadastroSaveResultDto { Ok = true, Id = entity.EtaIdEtapa };
    }

    public async Task<EtapaCadastroSaveResultDto> DeleteAsync(
        int obraId,
        int id,
        CancellationToken cancellationToken)
    {
        var entity = await _context.Etapas
            .FirstOrDefaultAsync(e => e.EtaIdEtapa == id && e.EtaIdObra == obraId, cancellationToken);
        if (entity == null)
        {
            return Fail("Etapa não encontrada.");
        }

        _context.Etapas.Remove(entity);
        try
        {
            await _context.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            return Fail("Não foi possível excluir a etapa. Existem registros dependentes!");
        }

        return new EtapaCadastroSaveResultDto { Ok = true, Id = id };
    }

    private static EtapaCadastroSaveResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };
}
