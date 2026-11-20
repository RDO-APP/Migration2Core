using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Aceite de convite — paridade prod <c>VerificarConvite</c> + <c>AcessoConvidada</c>.</summary>
public sealed class ConvidadaAceiteService
{
    private readonly RdoDbContext _context;

    public ConvidadaAceiteService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<ConvidadaBootstrapDto> BootstrapAsync(string? codigoConvite, CancellationToken cancellationToken)
    {
        var resolved = await ResolveConviteAsync(codigoConvite, cancellationToken);
        if (resolved.Error != null)
        {
            return new ConvidadaBootstrapDto { Ok = false, ErrorMessage = resolved.Error };
        }

        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new ConvidadaLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);

        var setores = await _context.Setores.AsNoTracking()
            .OrderBy(s => s.SetDsSetor)
            .Select(s => new ConvidadaLookupDto { Id = s.SetIdSetor, Nome = s.SetDsSetor ?? "" })
            .ToListAsync(cancellationToken);

        var ramos = await _context.Ramos.AsNoTracking()
            .OrderBy(r => r.RamDsRamo)
            .Select(r => new ConvidadaLookupDto { Id = r.RamIdRamo, Nome = r.RamDsRamo ?? "" })
            .ToListAsync(cancellationToken);

        var cargos = await _context.Cargos.AsNoTracking()
            .OrderBy(c => c.CarDsCargo)
            .Select(c => new ConvidadaLookupDto { Id = c.CarIdCargo, Nome = c.CarDsCargo ?? "" })
            .ToListAsync(cancellationToken);

        return new ConvidadaBootstrapDto
        {
            Ok = true,
            CodigoConvite = resolved.Codigo!,
            IdObra = resolved.IdObra,
            NomeObra = resolved.NomeObra,
            Papel = resolved.Papel,
            TipoConvite = resolved.TipoConvite,
            Ufs = ufs,
            Setores = setores,
            Ramos = ramos,
            Cargos = cargos,
        };
    }

    public async Task<IReadOnlyList<ConvidadaLookupDto>> MunicipiosAsync(int idUf, CancellationToken cancellationToken)
    {
        if (idUf <= 0)
        {
            return Array.Empty<ConvidadaLookupDto>();
        }

        return await _context.Municipios.AsNoTracking()
            .Where(m => m.MunIdUf == idUf)
            .OrderBy(m => m.MunDsMunicipio)
            .Select(m => new ConvidadaLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
            .ToListAsync(cancellationToken);
    }

    public async Task<ConvidadaEmpresaHintDto> EmpresaPorCnpjAsync(string? cnpjRaw, CancellationToken cancellationToken)
    {
        var cnpj = DigitsOnly(cnpjRaw);
        if (cnpj.Length != 14)
        {
            return new ConvidadaEmpresaHintDto { Found = false };
        }

        var row = await _context.Empresas.AsNoTracking()
            .Where(e => e.EmpNrCnpj == cnpj)
            .Select(e => new
            {
                e.EmpNrCnpj,
                e.EmpDsRazaoSocial,
                e.EmpNmFantasia,
                e.EmpIdSetor,
                e.EmpIdRamo,
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return new ConvidadaEmpresaHintDto { Found = false };
        }

        return new ConvidadaEmpresaHintDto
        {
            Found = true,
            Cnpj = row.EmpNrCnpj,
            RazaoSocial = row.EmpDsRazaoSocial,
            NomeFantasia = row.EmpNmFantasia,
            IdSetor = row.EmpIdSetor,
            IdRamo = row.EmpIdRamo,
        };
    }

    public async Task<ConvidadaColaboradorHintDto> ColaboradorPorCpfAsync(string? cpfRaw, CancellationToken cancellationToken)
    {
        var cpf = DigitsOnly(cpfRaw);
        if (cpf.Length != 11)
        {
            return new ConvidadaColaboradorHintDto { Found = false };
        }

        var row = await _context.Colaboradores.AsNoTracking()
            .Where(c => c.ColNrCpf == cpf)
            .Select(c => new
            {
                c.ColNrCpf,
                c.ColNmColaborador,
                c.ColDsEmail,
                c.ColDsTelefonePrincipal,
                c.ColIdMunicipio,
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return new ConvidadaColaboradorHintDto { Found = false };
        }

        int? idUf = null;
        if (row.ColIdMunicipio is > 0)
        {
            idUf = await _context.Municipios.AsNoTracking()
                .Where(m => m.MunIdMunicipio == row.ColIdMunicipio)
                .Select(m => (int?)m.MunIdUf)
                .FirstOrDefaultAsync(cancellationToken);
        }

        return new ConvidadaColaboradorHintDto
        {
            Found = true,
            Cpf = row.ColNrCpf,
            Nome = row.ColNmColaborador,
            Email = row.ColDsEmail,
            Telefone = row.ColDsTelefonePrincipal,
            IdUf = idUf,
            IdMunicipio = row.ColIdMunicipio,
        };
    }

    public async Task<(ConvidadaAcessarResultDto Result, Colaborador? Colaborador)> AcessarAsync(
        ConvidadaAcessarRequestDto request,
        CancellationToken cancellationToken)
    {
        var resolved = await ResolveConviteAsync(request.CodigoConvite, cancellationToken);
        if (resolved.Error != null)
        {
            return (Fail(resolved.Error), null);
        }

        var cnpj = DigitsOnly(request.CnpjEmpresa);
        var cpf = DigitsOnly(request.Cpf);
        var razao = (request.RazaoSocial ?? "").Trim();
        var fantasia = (request.NomeFantasia ?? "").Trim();
        var nome = (request.NomeColaborador ?? "").Trim();
        var email = (request.EmailColaborador ?? "").Trim();
        var telefone = DigitsOnly(request.TelefoneColaborador);
        var senha = request.Senha ?? "";
        var conf = request.ConfirmacaoSenha ?? "";

        if (cnpj.Length != 14) return (Fail("O CNPJ é inválido"), null);
        if (razao.Length < 3) return (Fail("A Razão Social deve ser preenchida"), null);
        if (fantasia.Length < 3) return (Fail("O Nome Fantasia deve ser preenchido"), null);
        if (cpf.Length != 11) return (Fail("O CPF é inválido"), null);
        if (nome.Length < 3) return (Fail("O Nome do Colaborador deve ser preenchido"), null);
        if (email.Length == 0 || !email.Contains('@') || !email.Contains('.'))
            return (Fail("O E-MAIL é inválido"), null);
        if (telefone.Length < 10) return (Fail("O Telefone deve ser preenchido"), null);
        if (request.IdMunicipio <= 0) return (Fail("O Município deve ser preenchido"), null);
        if (senha.Length < 4) return (Fail("Por favor, introduza pelo menos quatro caracteres na Senha"), null);
        if (senha != conf) return (Fail("As senhas digitadas devem ser idênticas."), null);
        if (request.Cargo <= 0) return (Fail("O Cargo deve ser preenchido."), null);

        var grupo = await _context.Grupos.AsNoTracking()
            .FirstOrDefaultAsync(
                g => g.GruStContratante == resolved.TipoConvite
                     && g.GruStDiretor == 1
                     && g.GruIdLicenca == resolved.IdLicenca,
                cancellationToken);
        if (grupo == null)
        {
            return (Fail("O grupo não pode ser identificado."), null);
        }

        var lado = resolved.TipoConvite == 1 ? "t" : "d";
        var senhaEnc = Seguranca.EncryptTripleDES(senha);

        // MySqlRetryingExecutionStrategy does not allow BeginTransaction outside CreateExecutionStrategy
        // (same pattern as RdoCadastroSaveService / M7).
        var strategy = _context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await _context.Database.BeginTransactionAsync(cancellationToken);
            try
            {
                var colaborador = await _context.Colaboradores
                    .FirstOrDefaultAsync(c => c.ColNrCpf == cpf, cancellationToken);
                if (colaborador == null)
                {
                    colaborador = new Colaborador
                    {
                        ColNrCpf = cpf,
                        ColNmColaborador = nome,
                        ColDsSenha = senhaEnc,
                    };
                    _context.Colaboradores.Add(colaborador);
                }
                else
                {
                    colaborador.ColNmColaborador = nome;
                    colaborador.ColDsSenha = senhaEnc;
                }

                colaborador.ColDsEmail = email;
                colaborador.ColDsTelefonePrincipal = telefone;
                colaborador.ColIdMunicipio = request.IdMunicipio;
                await _context.SaveChangesAsync(cancellationToken);

                var obraColab = await _context.ObraColaboradores
                    .FirstOrDefaultAsync(
                        oc => oc.OcoIdObra == resolved.IdObra && oc.OcoIdColaborador == colaborador.ColIdColaborador,
                        cancellationToken);
                if (obraColab == null)
                {
                    obraColab = new ObraColaborador
                    {
                        OcoIdObra = resolved.IdObra,
                        OcoIdColaborador = colaborador.ColIdColaborador,
                    };
                    _context.ObraColaboradores.Add(obraColab);
                }

                obraColab.OcoIdCargo = request.Cargo;
                obraColab.OcoIdGrupo = grupo.GruIdGrupo;
                obraColab.OcoStContratanteContratada = lado;
                obraColab.OcoDtContratacao = DateTime.Now.Date;
                await _context.SaveChangesAsync(cancellationToken);

                var empresa = await _context.Empresas
                    .FirstOrDefaultAsync(e => e.EmpNrCnpj == cnpj, cancellationToken);
                if (empresa == null)
                {
                    empresa = new Empresa
                    {
                        EmpNrCnpj = cnpj,
                        EmpDsLogradouro = "",
                        EmpDsNumero = "",
                        EmpDsBairro = "",
                        EmpDsCep = "",
                        EmpDsLogo = "",
                        EmpDsTelefone = "",
                        EmpDsComplemento = "",
                        EmpIdToken = "",
                    };
                    _context.Empresas.Add(empresa);
                }

                empresa.EmpDsRazaoSocial = razao;
                empresa.EmpNmFantasia = fantasia;
                empresa.EmpIdSetor = request.IdSetor > 0 ? request.IdSetor : null;
                empresa.EmpIdRamo = request.IdRamo > 0 ? request.IdRamo : null;
                empresa.EmpIdColaborador = colaborador.ColIdColaborador;
                empresa.EmpIdLicenca = resolved.IdLicenca;
                empresa.EmpIdMunicipio = null;
                await _context.SaveChangesAsync(cancellationToken);

                var obraEntity = await _context.Obras
                    .FirstOrDefaultAsync(o => o.ObrIdObra == resolved.IdObra, cancellationToken);
                if (obraEntity == null)
                {
                    await tx.RollbackAsync(cancellationToken);
                    return (Fail("Obra não encontrada."), null);
                }

                if (resolved.TipoConvite == 1)
                {
                    obraEntity.ObrIdEmpresaContratante = empresa.EmpIdEmpresa;
                }
                else
                {
                    obraEntity.ObrIdEmpresaContratada = empresa.EmpIdEmpresa;
                }

                obraEntity.ObrCdConvite = null;
                await _context.SaveChangesAsync(cancellationToken);
                await tx.CommitAsync(cancellationToken);

                return (new ConvidadaAcessarResultDto
                {
                    Ok = true,
                    RedirectUrl = "/Obra/Escolher",
                    ColaboradorId = colaborador.ColIdColaborador,
                }, colaborador);
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync(cancellationToken);
                return (Fail($"Erro ao aceitar convite: {ex.Message}"), null);
            }
        });
    }

    private async Task<ResolvedConvite> ResolveConviteAsync(string? codigoRaw, CancellationToken cancellationToken)
    {
        var codigo = (codigoRaw ?? "").Trim();
        if (codigo.Length == 0)
        {
            return ResolvedConvite.Fail("Parametro da obra não foi definido");
        }

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrCdConvite == codigo)
            .Select(o => new
            {
                o.ObrIdObra,
                Nome = (string?)o.ObrDsObra,
                o.ObrIdEmpresaContratante,
                o.ObrIdEmpresaContratada,
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (obra == null)
        {
            return ResolvedConvite.Fail("Este convite já foi utilizado ou não existe.");
        }

        int tipoConvite;
        string papel;
        if (obra.ObrIdEmpresaContratante == null)
        {
            tipoConvite = 1;
            papel = "CONTRATANTE";
        }
        else if (obra.ObrIdEmpresaContratada == null)
        {
            tipoConvite = 2;
            papel = "CONTRATADA";
        }
        else
        {
            return ResolvedConvite.Fail("A obra já possui as duas empresas");
        }

        var idLicenca = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join g in _context.Grupos.AsNoTracking() on oc.OcoIdGrupo equals g.GruIdGrupo
            where oc.OcoIdObra == obra.ObrIdObra && g.GruIdLicenca != null
            select g.GruIdLicenca!.Value
        ).FirstOrDefaultAsync(cancellationToken);

        if (idLicenca <= 0)
        {
            return ResolvedConvite.Fail("A licença da obra não pode ser identificada.");
        }

        return new ResolvedConvite
        {
            Codigo = codigo,
            IdObra = obra.ObrIdObra,
            NomeObra = obra.Nome ?? "",
            TipoConvite = tipoConvite,
            Papel = papel,
            IdLicenca = idLicenca,
        };
    }

    private static ConvidadaAcessarResultDto Fail(string msg) =>
        new() { Ok = false, ErrorMessage = msg };

    private static string DigitsOnly(string? raw) =>
        Regex.Replace(raw ?? "", @"\D", "");

    private sealed class ResolvedConvite
    {
        public string? Error { get; init; }
        public string? Codigo { get; init; }
        public int IdObra { get; init; }
        public string NomeObra { get; init; } = "";
        public int TipoConvite { get; init; }
        public string Papel { get; init; } = "";
        public int IdLicenca { get; init; }

        public static ResolvedConvite Fail(string error) => new() { Error = error };
    }
}
