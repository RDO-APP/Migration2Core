using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Menu ☰ Códigos de Paralizações — paridade prod index/cadastro (catálogo global; CAT-PARALIZ-01 depois).</summary>
public class ParalizacaoService
{
    private const string PermissionRoute = "/tarefa/paralizacoes/index";
    private readonly RdoDbContext _context;

    public ParalizacaoService(RdoDbContext context)
    {
        _context = context;
    }

    public static bool Can(HttpContext httpContext, string permission) =>
        PermissionHelper.HasPermission(httpContext, permission, PermissionRoute);

    public Task<ParalizacaoIndexBootstrapDto> BootstrapAsync(
        HttpContext httpContext,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        _ = cancellationToken;
        var canEditar = Can(httpContext, "editar");
        return Task.FromResult(new ParalizacaoIndexBootstrapDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Permissions = new ParalizacaoIndexPermissionsDto
            {
                ShowEditar = canEditar,
                ShowDeletar = Can(httpContext, "deletar"),
                ShowNovo = Can(httpContext, "criarNovo"),
            },
        });
    }

    public async Task<ParalizacaoIndexListResponseDto> ListAsync(
        HttpContext httpContext,
        ParalizacaoIndexFilterDto filter,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var canEditar = Can(httpContext, "editar");
        var canDeletar = Can(httpContext, "deletar");

        var q = _context.TarefaCodigoParalizacoes.AsNoTracking().AsQueryable();
        var descricao = (filter.Descricao ?? "").Trim();
        if (descricao.Length > 0)
        {
            var lower = descricao.ToLowerInvariant();
            q = q.Where(x => x.TarcpDsParalizacao.ToLower().Contains(lower));
        }

        var rows = await q
            .OrderBy(x => x.TarcpCodigoParalizacao)
            .Select(x => new { x.TarcpCodigoParalizacao, x.TarcpDsParalizacao })
            .ToListAsync(cancellationToken);

        return new ParalizacaoIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = rows.Select(r => new ParalizacaoIndexItemDto
            {
                Codigo = r.TarcpCodigoParalizacao ?? "",
                Descricao = r.TarcpDsParalizacao ?? "",
                Editavel = canEditar,
                Excluivel = canDeletar,
            }).ToList(),
        };
    }

    public async Task<(ParalizacaoCadastroFormDto? Form, string? Error)> GetFormAsync(
        HttpContext httpContext,
        string? codigo,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var code = NormalizeCodigo(codigo);
        var isNew = string.IsNullOrEmpty(code);
        var canNovo = Can(httpContext, "criarNovo");
        var canEditar = Can(httpContext, "editar");

        if (isNew)
        {
            if (!canNovo)
            {
                return (null, "Sem permissão para criar código de paralização.");
            }

            return (new ParalizacaoCadastroFormDto
            {
                PodeSalvar = true,
                ObraNomeSessao = obraNomeSessao ?? "",
            }, null);
        }

        var row = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .FirstOrDefaultAsync(x => x.TarcpCodigoParalizacao == code, cancellationToken);
        if (row == null)
        {
            return (null, "Código de paralização não encontrado.");
        }

        return (new ParalizacaoCadastroFormDto
        {
            Codigo = row.TarcpCodigoParalizacao,
            Descricao = row.TarcpDsParalizacao ?? "",
            Update = true,
            PodeSalvar = canEditar,
            ObraNomeSessao = obraNomeSessao ?? "",
        }, null);
    }

    public async Task<ParalizacaoCadastroSaveResultDto> SaveAsync(
        HttpContext httpContext,
        ParalizacaoCadastroSaveRequestDto body,
        CancellationToken cancellationToken)
    {
        var codigo = NormalizeCodigo(body.Codigo);
        var descricao = (body.Descricao ?? "").Trim();

        if (string.IsNullOrEmpty(codigo))
        {
            return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "O Código deve ser preenchido." };
        }

        if (codigo.Length > 3)
        {
            return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "O Código deve ter no máximo 3 caracteres." };
        }

        if (string.IsNullOrEmpty(descricao))
        {
            return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "A Descrição deve ser preenchida." };
        }

        if (descricao.Length > 100)
        {
            return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "A Descrição deve ter no máximo 100 caracteres." };
        }

        if (body.Update)
        {
            if (!Can(httpContext, "editar"))
            {
                return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "Sem permissão para editar." };
            }

            var entity = await _context.TarefaCodigoParalizacoes
                .FirstOrDefaultAsync(x => x.TarcpCodigoParalizacao == codigo, cancellationToken);
            if (entity == null)
            {
                return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "Código de paralização não encontrado." };
            }

            entity.TarcpDsParalizacao = descricao;
            await _context.SaveChangesAsync(cancellationToken);
            return new ParalizacaoCadastroSaveResultDto { Ok = true, Codigo = codigo };
        }

        if (!Can(httpContext, "criarNovo"))
        {
            return new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "Sem permissão para criar." };
        }

        var exists = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .AnyAsync(x => x.TarcpCodigoParalizacao == codigo, cancellationToken);
        if (exists)
        {
            return new ParalizacaoCadastroSaveResultDto
            {
                Ok = false,
                ErrorMessage = $"Já existe uma Paralização com o código {codigo}. Favor informar outro código!",
            };
        }

        _context.TarefaCodigoParalizacoes.Add(new TarefaCodigoParalizacao
        {
            TarcpCodigoParalizacao = codigo,
            TarcpDsParalizacao = descricao,
        });
        await _context.SaveChangesAsync(cancellationToken);
        return new ParalizacaoCadastroSaveResultDto { Ok = true, Codigo = codigo };
    }

    public async Task<ParalizacaoIndexActionResultDto> DeleteAsync(
        HttpContext httpContext,
        string? codigo,
        CancellationToken cancellationToken)
    {
        if (!Can(httpContext, "deletar"))
        {
            return new ParalizacaoIndexActionResultDto { Ok = false, ErrorMessage = "Sem permissão para excluir." };
        }

        var code = NormalizeCodigo(codigo);
        if (string.IsNullOrEmpty(code))
        {
            return new ParalizacaoIndexActionResultDto { Ok = false, ErrorMessage = "Código inválido." };
        }

        var entity = await _context.TarefaCodigoParalizacoes
            .FirstOrDefaultAsync(x => x.TarcpCodigoParalizacao == code, cancellationToken);
        if (entity == null)
        {
            return new ParalizacaoIndexActionResultDto { Ok = false, ErrorMessage = "Código de paralização não encontrado." };
        }

        try
        {
            _context.TarefaCodigoParalizacoes.Remove(entity);
            await _context.SaveChangesAsync(cancellationToken);
            return new ParalizacaoIndexActionResultDto { Ok = true };
        }
        catch (DbUpdateException)
        {
            return new ParalizacaoIndexActionResultDto
            {
                Ok = false,
                ErrorMessage = "Não foi possível excluir: o código está em uso em tarefas.",
            };
        }
    }

    private static string NormalizeCodigo(string? raw) =>
        string.IsNullOrWhiteSpace(raw) ? "" : raw.Trim().ToUpperInvariant();
}
