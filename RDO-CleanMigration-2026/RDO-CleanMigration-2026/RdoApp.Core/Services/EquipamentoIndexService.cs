using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Menu ☰ Equipamentos — listagem/filtros/ações (paridade Equipamentos/index.html · EquipamentosModel.Lista).</summary>
public class EquipamentoIndexService
{
    private static readonly string[] PermissionRoutes = ["/equipamentos/index", "/equipamento/index"];
    private readonly RdoDbContext _context;

    public EquipamentoIndexService(RdoDbContext context)
    {
        _context = context;
    }

    public static bool CanEquipamentoIndex(HttpContext httpContext, string permission) =>
        PermissionRoutes.Any(route => PermissionHelper.HasPermission(httpContext, permission, route));

    public EquipamentoIndexBootstrapDto Bootstrap(HttpContext httpContext, string? obraNomeSessao) =>
        new()
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Permissions = new EquipamentoIndexPermissionsDto
            {
                ShowVisualizar = CanEquipamentoIndex(httpContext, "visualizarRegistro"),
                ShowEditar = CanEquipamentoIndex(httpContext, "editar"),
                ShowDeletar = CanEquipamentoIndex(httpContext, "deletar"),
                ShowNovo = CanEquipamentoIndex(httpContext, "criarNovo"),
            },
        };

    public async Task<EquipamentoIndexListResponseDto> ListAsync(
        int obraId,
        EquipamentoIndexFilterDto filter,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return new EquipamentoIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        var q =
            from oe in _context.ObraEquipamentos.AsNoTracking()
            join eq in _context.Equipamentos.AsNoTracking() on oe.OeqIdEquipamento equals eq.EquIdEquipamento
            join te in _context.TipoEquipamentos.AsNoTracking() on eq.EquIdTipoEquipamento equals te.TeqIdTipoEquipamento into tej
            from te in tej.DefaultIfEmpty()
            where oe.OeqIdObra == obraId
            select new
            {
                eq.EquIdEquipamento,
                oe.OeqIdObraEquipamento,
                Descricao = eq.EquDsEquipamento ?? "",
                Marca = eq.EquDsMarca ?? "",
                Modelo = eq.EquDsModelo ?? "",
                TipoEquipamento = te != null ? te.TeqNmTipoEquipamento ?? "" : "",
                TipoAquisicao = oe.OeqTpAquisicao ?? "",
                FabricanteFornecedor = oe.OeqDsFabricanteFornecedor ?? "",
                Contato = oe.OeqDsContato ?? "",
                Telefone = oe.OeqDsTelefone ?? "",
            };

        var tipoEq = (filter.TipoEquipamento ?? "").Trim();
        if (tipoEq.Length > 0)
        {
            var lower = tipoEq.ToLowerInvariant();
            q = q.Where(x => x.TipoEquipamento.ToLower().Contains(lower));
        }

        var descricao = (filter.Descricao ?? "").Trim();
        if (descricao.Length > 0)
        {
            var lower = descricao.ToLowerInvariant();
            q = q.Where(x => x.Descricao.ToLower().Contains(lower));
        }

        var marca = (filter.Marca ?? "").Trim();
        if (marca.Length > 0)
        {
            var lower = marca.ToLowerInvariant();
            q = q.Where(x => x.Marca.ToLower().Contains(lower));
        }

        var modelo = (filter.Modelo ?? "").Trim();
        if (modelo.Length > 0)
        {
            var lower = modelo.ToLowerInvariant();
            q = q.Where(x => x.Modelo.ToLower().Contains(lower));
        }

        var tipoAquisicao = (filter.TipoAquisicao ?? "S").Trim();
        if (!string.IsNullOrEmpty(tipoAquisicao) && tipoAquisicao != "S")
        {
            q = q.Where(x => x.TipoAquisicao == tipoAquisicao);
        }

        var fabricante = (filter.FabricanteFornecedor ?? "").Trim();
        if (fabricante.Length > 0)
        {
            var lower = fabricante.ToLowerInvariant();
            q = q.Where(x => x.FabricanteFornecedor.ToLower().Contains(lower));
        }

        var rows = await q.OrderBy(x => x.Descricao).ToListAsync(cancellationToken);
        var items = rows.Select(r => new EquipamentoIndexItemDto
        {
            IdEquipamento = r.EquIdEquipamento,
            IdObraEquipamento = r.OeqIdObraEquipamento,
            TipoEquipamento = r.TipoEquipamento,
            Descricao = r.Descricao,
            FabricanteFornecedor = r.FabricanteFornecedor,
            Contato = r.Contato,
            Telefone = FormatPhone(r.Telefone),
        }).ToList();

        return new EquipamentoIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = items,
        };
    }

    public async Task<EquipamentoIndexActionResultDto> DeleteAsync(
        int equipamentoId,
        int obraId,
        CancellationToken cancellationToken)
    {
        if (equipamentoId <= 0 || obraId <= 0)
        {
            return new EquipamentoIndexActionResultDto { Ok = false, ErrorMessage = "Equipamento inválido." };
        }

        var links = await _context.ObraEquipamentos
            .Where(oe => oe.OeqIdObra == obraId && oe.OeqIdEquipamento == equipamentoId)
            .ToListAsync(cancellationToken);

        if (links.Count == 0)
        {
            return new EquipamentoIndexActionResultDto { Ok = false, ErrorMessage = "Equipamento não está nesta obra." };
        }

        var obraEquipamentoIds = links.Select(l => l.OeqIdObraEquipamento).ToList();
        var temTarefa = await _context.ObraTarefaEquipamentos.AsNoTracking()
            .AnyAsync(ote => obraEquipamentoIds.Contains(ote.OteIdObraEquipamento), cancellationToken);
        if (temTarefa)
        {
            return new EquipamentoIndexActionResultDto
            {
                Ok = false,
                ErrorMessage = "Não é possível excluir este equipamento. Já existem registros dependentes.",
            };
        }

        try
        {
            _context.ObraEquipamentos.RemoveRange(links);

            var aindaUsado = await _context.ObraEquipamentos.AsNoTracking()
                .AnyAsync(
                    oe => oe.OeqIdEquipamento == equipamentoId && oe.OeqIdObra != obraId,
                    cancellationToken);
            if (!aindaUsado)
            {
                var equipamento = await _context.Equipamentos
                    .FirstOrDefaultAsync(e => e.EquIdEquipamento == equipamentoId, cancellationToken);
                if (equipamento != null)
                {
                    _context.Equipamentos.Remove(equipamento);
                }
            }

            await _context.SaveChangesAsync(cancellationToken);
            return new EquipamentoIndexActionResultDto { Ok = true };
        }
        catch (DbUpdateException)
        {
            return new EquipamentoIndexActionResultDto
            {
                Ok = false,
                ErrorMessage = "Não é possível excluir este equipamento. Já existem registros dependentes.",
            };
        }
    }

    private static string DigitsOnly(string? value) =>
        string.IsNullOrWhiteSpace(value) ? "" : new string(value.Where(char.IsDigit).ToArray());

    private static string FormatPhone(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length == 11)
        {
            return $"({d[..2]}) {d[2..7]}-{d[7..]}";
        }

        if (d.Length == 10)
        {
            return $"({d[..2]}) {d[2..6]}-{d[6..]}";
        }

        return raw?.Trim() ?? "";
    }
}
