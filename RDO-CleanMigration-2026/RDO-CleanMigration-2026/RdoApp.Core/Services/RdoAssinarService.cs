using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 7d — paridade prod <c>RdoModel.Assinar</c>.</summary>
public class RdoAssinarService
{
    private readonly RdoDbContext _context;

    public RdoAssinarService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<RdoAssinarResultDto> AssinarAsync(
        int obraId,
        int colaboradorId,
        int idObraColaboradorSessao,
        int idRdo,
        RdoAssinarRequestDto body,
        string fallbackIp,
        CancellationToken cancellationToken)
    {
        var rdo = await _context.Rdos
            .FirstOrDefaultAsync(r => r.RdoIdRdo == idRdo && r.RdoIdObra == obraId, cancellationToken);
        if (rdo == null)
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "RDO não encontrado para esta obra." };
        }

        var oc = await ResolveAssinanteAsync(obraId, colaboradorId, idObraColaboradorSessao, cancellationToken);
        if (oc == null)
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Colaborador da obra não encontrado para assinar." };
        }

        var tipoAssinante = await ResolveTipoAssinanteAsync(oc, cancellationToken);
        if (tipoAssinante is not ("t" or "d"))
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Perfil contratante/contratada não identificado." };
        }

        if (AssinarEditarBloqueado(rdo.RdoIdStatus, tipoAssinante))
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Este RDO não pode ser assinado no status atual." };
        }

        var statusLabel = await _context.StatusRdos.AsNoTracking()
            .Where(s => s.StrIdStatus == rdo.RdoIdStatus)
            .Select(s => (string?)s.StrDsStatus)
            .FirstOrDefaultAsync(cancellationToken) ?? "";
        var statusLower = statusLabel.ToLowerInvariant();

        if (statusLower.Contains("contratada") && tipoAssinante == "d")
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Esse RDO já foi assinado pela contratada." };
        }

        if (statusLower.Contains("contratante") && tipoAssinante == "d")
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Esse RDO já foi assinado pela contratada." };
        }

        if (statusLower.Contains("contratante") && tipoAssinante == "t")
        {
            return new RdoAssinarResultDto { Ok = false, ErrorMessage = "Esse RDO já foi assinado pela contratante." };
        }

        rdo.RdoIdStatus = tipoAssinante == "t" ? 2 : 3;

        var comentario = (body.ComentarioAssinatura ?? "").Trim();
        if (comentario.Length > 0)
        {
            rdo.RdoDsComentarioAssinatura = comentario;
            rdo.RdoTpComentarioAssinatura = body.TipoComentarioAssinatura == 1
                ? "P"
                : body.TipoComentarioAssinatura == 2
                    ? "N"
                    : "";
        }

        var ip = string.IsNullOrWhiteSpace(body.Ip) ? fallbackIp : body.Ip.Trim();
        if (ip.Length > 64)
        {
            ip = ip[..64];
        }

        var assinatura = await _context.AssinaturaRdos
            .FirstOrDefaultAsync(
                a => a.AssIdRdo == idRdo && a.AssIdObraColaboradorAssinante == oc.OcoIdObraColaborador,
                cancellationToken);
        if (assinatura == null)
        {
            _context.AssinaturaRdos.Add(new Data.Entities.AssinaturaRdo
            {
                AssIdObraColaboradorAssinante = oc.OcoIdObraColaborador,
                AssIdRdo = idRdo,
                AssDtAssinatura = DateTime.Now,
                AssDsIp = ip,
            });
        }
        else
        {
            assinatura.AssDtAssinatura = DateTime.Now;
            assinatura.AssDsIp = ip;
        }

        await _context.SaveChangesAsync(cancellationToken);
        return new RdoAssinarResultDto { Ok = true };
    }

    /// <summary>Paridade <c>habilitarAssinarRdo</c> — true = bloqueado.</summary>
    public static bool AssinarEditarBloqueado(int statusRdo, string contratanteContratada)
    {
        var cc = (contratanteContratada ?? "").Trim().ToLowerInvariant();
        if (cc == "t" && statusRdo == 1) return true;
        if (cc == "t" && statusRdo == 3) return false;
        if (cc == "d" && statusRdo == 1) return false;
        if (cc == "d" && statusRdo == 3) return true;
        if (statusRdo == 2) return true;
        return true;
    }

    private async Task<Data.Entities.ObraColaborador?> ResolveAssinanteAsync(
        int obraId,
        int colaboradorId,
        int idObraColaboradorSessao,
        CancellationToken cancellationToken)
    {
        if (colaboradorId > 0)
        {
            var byPair = await _context.ObraColaboradores
                .FirstOrDefaultAsync(
                    o => o.OcoIdObra == obraId && o.OcoIdColaborador == colaboradorId,
                    cancellationToken);
            if (byPair != null)
            {
                return byPair;
            }
        }

        if (idObraColaboradorSessao > 0)
        {
            return await _context.ObraColaboradores
                .FirstOrDefaultAsync(
                    o => o.OcoIdObraColaborador == idObraColaboradorSessao && o.OcoIdObra == obraId,
                    cancellationToken);
        }

        return null;
    }

    private async Task<string> ResolveTipoAssinanteAsync(
        Data.Entities.ObraColaborador oc,
        CancellationToken cancellationToken)
    {
        var st = (oc.OcoStContratanteContratada ?? "").Trim().ToLowerInvariant();
        if (st is "t" or "d")
        {
            return st;
        }

        var nomeGrupo = await _context.Grupos.AsNoTracking()
            .Where(g => g.GruIdGrupo == oc.OcoIdGrupo)
            .Select(g => (string?)g.GruNmNome)
            .FirstOrDefaultAsync(cancellationToken) ?? "";
        var lower = nomeGrupo.ToLowerInvariant();
        if (lower.Contains("contratante"))
        {
            return "t";
        }

        if (lower.Contains("contratada"))
        {
            return "d";
        }

        return "";
    }
}
