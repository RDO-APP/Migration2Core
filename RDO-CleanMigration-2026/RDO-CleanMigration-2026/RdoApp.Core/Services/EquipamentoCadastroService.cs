using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>Cadastro Equipamento — paridade Equipamentos/cadastro.html · EquipamentosModel.ObterRegistro/Salvar.</summary>
public class EquipamentoCadastroService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public EquipamentoCadastroService(RdoDbContext context)
    {
        _context = context;
    }

    public static bool CanCriarNovo(HttpContext httpContext) =>
        EquipamentoIndexService.CanEquipamentoIndex(httpContext, "criarNovo");

    public static bool CanEditar(HttpContext httpContext) =>
        EquipamentoIndexService.CanEquipamentoIndex(httpContext, "editar");

    public async Task<(EquipamentoCadastroFormDto? Form, string? Error)> GetFormAsync(
        HttpContext httpContext,
        int equipamentoId,
        int obraId,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return (null, "Nenhuma obra selecionada.");
        }

        if (equipamentoId <= 0)
        {
            if (!CanCriarNovo(httpContext))
            {
                return (null, "Sem permissão para criar equipamento.");
            }

            return (Blank(obraNomeSessao, podeSalvar: true), null);
        }

        var row = await (
            from oe in _context.ObraEquipamentos.AsNoTracking()
            join eq in _context.Equipamentos.AsNoTracking() on oe.OeqIdEquipamento equals eq.EquIdEquipamento
            join te in _context.TipoEquipamentos.AsNoTracking() on eq.EquIdTipoEquipamento equals te.TeqIdTipoEquipamento into tej
            from te in tej.DefaultIfEmpty()
            where oe.OeqIdObra == obraId && eq.EquIdEquipamento == equipamentoId
            select new
            {
                eq.EquIdEquipamento,
                oe.OeqIdObraEquipamento,
                Descricao = eq.EquDsEquipamento ?? "",
                Marca = eq.EquDsMarca ?? "",
                Modelo = eq.EquDsModelo ?? "",
                Tipo = te != null ? te.TeqNmTipoEquipamento ?? "" : "",
                TipoAquisicao = oe.OeqTpAquisicao ?? "S",
                oe.OeqDtAquisicao,
                Fabricante = oe.OeqDsFabricanteFornecedor ?? "",
                Contato = oe.OeqDsContato ?? "",
                Telefone = oe.OeqDsTelefone ?? "",
            }).FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return (null, "Equipamento não encontrado nesta obra.");
        }

        return (new EquipamentoCadastroFormDto
        {
            IdEquipamento = row.EquIdEquipamento,
            IdObraEquipamento = row.OeqIdObraEquipamento,
            TipoEquipamento = row.Tipo,
            Descricao = row.Descricao,
            Marca = row.Marca,
            Modelo = row.Modelo,
            TipoAquisicao = string.IsNullOrWhiteSpace(row.TipoAquisicao) ? "S" : row.TipoAquisicao,
            DataAquisicao = row.OeqDtAquisicao.HasValue
                ? row.OeqDtAquisicao.Value.ToString("dd/MM/yyyy", PtBr)
                : "",
            FabricanteFornecedor = row.Fabricante,
            Contato = row.Contato,
            Telefone = FormatPhone(row.Telefone),
            PodeSalvar = CanEditar(httpContext),
            ObraNomeSessao = obraNomeSessao ?? "",
        }, null);
    }

    public async Task<EquipamentoCadastroSaveResultDto> SaveAsync(
        HttpContext httpContext,
        int obraId,
        EquipamentoCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return Fail("Nenhuma obra selecionada.");
        }

        var isNew = request.IdEquipamento <= 0;
        if (isNew && !CanCriarNovo(httpContext))
        {
            return Fail("Sem permissão para criar equipamento.");
        }

        if (!isNew && !CanEditar(httpContext))
        {
            return Fail("Sem permissão para editar equipamento.");
        }

        var tipoNome = (request.TipoEquipamento ?? "").Trim();
        if (tipoNome.Length == 0)
        {
            return Fail("O Tipo de equipamento deve ser preenchido.");
        }

        var descricao = (request.Descricao ?? "").Trim();
        if (descricao.Length < 2)
        {
            return Fail("A Descrição deve ser preenchida.");
        }

        DateTime? dataAquisicao = null;
        var dataRaw = (request.DataAquisicao ?? "").Trim();
        if (dataRaw.Length > 0)
        {
            if (!DateTime.TryParseExact(dataRaw, "dd/MM/yyyy", PtBr, DateTimeStyles.None, out var parsed))
            {
                return Fail("A Data de Aquisição é inválida.");
            }

            dataAquisicao = parsed.Date;
        }

        var telefone = DigitsOnly(request.Telefone);
        if (!string.IsNullOrWhiteSpace(request.Telefone) && telefone.Length is > 0 and < 10)
        {
            return Fail("O Telefone é inválido.");
        }

        var tipoId = await ResolveTipoIdAsync(tipoNome, cancellationToken);
        Equipamento equipamento;
        if (isNew)
        {
            equipamento = new Equipamento
            {
                EquDsEquipamento = descricao,
                EquDsMarca = (request.Marca ?? "").Trim(),
                EquDsModelo = (request.Modelo ?? "").Trim(),
                EquIdTipoEquipamento = tipoId,
                EquDsImagem = "",
            };
            _context.Equipamentos.Add(equipamento);
            await _context.SaveChangesAsync(cancellationToken);
        }
        else
        {
            equipamento = await _context.Equipamentos
                .FirstOrDefaultAsync(e => e.EquIdEquipamento == request.IdEquipamento, cancellationToken)
                ?? null!;
            if (equipamento == null)
            {
                return Fail("Equipamento não encontrado.");
            }

            equipamento.EquDsEquipamento = descricao;
            equipamento.EquDsMarca = (request.Marca ?? "").Trim();
            equipamento.EquDsModelo = (request.Modelo ?? "").Trim();
            equipamento.EquIdTipoEquipamento = tipoId;
        }

        var obraEquip = await _context.ObraEquipamentos
            .FirstOrDefaultAsync(
                oe => oe.OeqIdObra == obraId && oe.OeqIdEquipamento == equipamento.EquIdEquipamento,
                cancellationToken);

        if (obraEquip == null)
        {
            obraEquip = new ObraEquipamento
            {
                OeqIdObra = obraId,
                OeqIdEquipamento = equipamento.EquIdEquipamento,
            };
            _context.ObraEquipamentos.Add(obraEquip);
        }

        var tipoAq = (request.TipoAquisicao ?? "S").Trim();
        obraEquip.OeqTpAquisicao = tipoAq is "A" or "C" ? tipoAq : "S";
        obraEquip.OeqDsFabricanteFornecedor = (request.FabricanteFornecedor ?? "").Trim();
        obraEquip.OeqDtAquisicao = dataAquisicao;
        obraEquip.OeqDsContato = (request.Contato ?? "").Trim();
        obraEquip.OeqDsTelefone = telefone;

        await _context.SaveChangesAsync(cancellationToken);
        return new EquipamentoCadastroSaveResultDto { Ok = true, IdEquipamento = equipamento.EquIdEquipamento };
    }

    private async Task<int> ResolveTipoIdAsync(string nome, CancellationToken cancellationToken)
    {
        var lower = nome.ToLowerInvariant();
        var existing = await _context.TipoEquipamentos
            .FirstOrDefaultAsync(
                t => t.TeqNmTipoEquipamento != null && t.TeqNmTipoEquipamento.ToLower().Contains(lower),
                cancellationToken);
        if (existing != null)
        {
            return existing.TeqIdTipoEquipamento;
        }

        var created = new TipoEquipamento
        {
            TeqNmTipoEquipamento = nome,
            TeqDsTipoEquipamento = "",
        };
        _context.TipoEquipamentos.Add(created);
        await _context.SaveChangesAsync(cancellationToken);
        return created.TeqIdTipoEquipamento;
    }

    private static EquipamentoCadastroFormDto Blank(string? obraNome, bool podeSalvar) =>
        new()
        {
            TipoAquisicao = "S",
            PodeSalvar = podeSalvar,
            ObraNomeSessao = obraNome ?? "",
        };

    private static EquipamentoCadastroSaveResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };

    private static string DigitsOnly(string? value) =>
        string.IsNullOrWhiteSpace(value) ? "" : new string(value.Where(char.IsDigit).ToArray());

    private static string FormatPhone(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length == 11) return $"({d[..2]}) {d[2..7]}-{d[7..]}";
        if (d.Length == 10) return $"({d[..2]}) {d[2..6]}-{d[6..]}";
        return raw?.Trim() ?? "";
    }
}
