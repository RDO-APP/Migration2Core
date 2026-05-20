using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data;

/// <summary>
/// Database context for RDO Application
/// Phase 1: Testing with UF and Municipio only
/// Other entities will be added as they are fully implemented with Fluent API configurations
/// </summary>
public class RdoDbContext : IdentityDbContext<ApplicationUser>
{
    public RdoDbContext(DbContextOptions<RdoDbContext> options)
        : base(options)
    {
    }

    #region Geographic Entities (Phase 1 - Fully Implemented)
    public DbSet<UF> UFs { get; set; } = null!;
    public DbSet<Municipio> Municipios { get; set; } = null!;
    #endregion

    #region Reference/Lookup Tables (Phase 1 - Fully Implemented)
    public DbSet<Cargo> Cargos { get; set; } = null!;
    public DbSet<Setor> Setores { get; set; } = null!;
    public DbSet<Ramo> Ramos { get; set; } = null!;
    public DbSet<StatusTarefa> StatusTarefas { get; set; } = null!;
    public DbSet<StatusRdo> StatusRdos { get; set; } = null!;
    public DbSet<EfetivoStatus> EfetivoStatuses { get; set; } = null!;
    public DbSet<TipoEquipamento> TipoEquipamentos { get; set; } = null!;
    public DbSet<UnidadeDeMedida> UnidadesDeMedida { get; set; } = null!;
    #endregion

    #region Company Entities (Phase 1 - Fully Implemented)
    public DbSet<Licenca> Licencas { get; set; } = null!;
    public DbSet<Empresa> Empresas { get; set; } = null!;
    #endregion

    #region Personnel Entities (Phase 1 - Fully Implemented)
    public DbSet<Colaborador> Colaboradores { get; set; } = null!;
    #endregion

    #region Equipment Entities (Phase 1 - Fully Implemented)
    public DbSet<Equipamento> Equipamentos { get; set; } = null!;
    public DbSet<Marca> Marcas { get; set; } = null!;
    public DbSet<Modelo> Modelos { get; set; } = null!;
    #endregion

    #region Work Management Entities (Phase 2 - Fully Implemented)
    public DbSet<Obra> Obras { get; set; } = null!;
    public DbSet<Etapa> Etapas { get; set; } = null!;
    public DbSet<Tarefa> Tarefas { get; set; } = null!;
    public DbSet<TarefaCodigoParalizacao> TarefaCodigoParalizacoes { get; set; } = null!;
    #endregion

    #region Assignment Entities (Phase 3 - Fully Implemented)
    public DbSet<ObraColaborador> ObraColaboradores { get; set; } = null!;
    public DbSet<ObraEquipamento> ObraEquipamentos { get; set; } = null!;
    public DbSet<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; } = null!;
    public DbSet<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; } = null!;
    #endregion

    #region Daily Report Entities (Phase 4 - Fully Implemented)
    public DbSet<Rdo> Rdos { get; set; } = null!;
    public DbSet<RdoTarefa> RdoTarefas { get; set; } = null!;
    public DbSet<RdoImagem> RdoImagens { get; set; } = null!;
    public DbSet<AssinaturaRdo> AssinaturaRdos { get; set; } = null!;
    public DbSet<Improdutividade> Improdutividades { get; set; } = null!;
    #endregion

    #region Quality Control & Incidents (Phase 5 - Fully Implemented)
    public DbSet<Laudo> Laudos { get; set; } = null!;
    public DbSet<Efetivo> Efetivos { get; set; } = null!;
    public DbSet<Acidente> Acidentes { get; set; } = null!;
    public DbSet<AcidenteColaborador> AcidenteColaboradores { get; set; } = null!;
    #endregion

    #region History/Audit (Phase 6 - Fully Implemented)
    public DbSet<HistoricoTarefaRdo> HistoricoTarefaRdos { get; set; } = null!;
    public DbSet<HistoricoTarefaColaborador> HistoricoTarefaColaboradores { get; set; } = null!;
    public DbSet<HistoricoTarefaEquipamento> HistoricoTarefaEquipamentos { get; set; } = null!;
    public DbSet<HistoricoLogin> HistoricoLogins { get; set; } = null!;
    #endregion

    #region Security/RBAC (Phase 7 - Fully Implemented)
    public DbSet<Usuario> Usuarios { get; set; } = null!;
    public DbSet<Grupo> Grupos { get; set; } = null!;
    public DbSet<Menu> Menus { get; set; } = null!;
    public DbSet<MenuPagina> MenuPaginas { get; set; } = null!;
    public DbSet<Pagina> Paginas { get; set; } = null!;
    public DbSet<Acao> Acoes { get; set; } = null!;
    public DbSet<PaginaAcao> PaginaAcoes { get; set; } = null!;
    public DbSet<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; } = null!;
    public DbSet<PerfilAssinante> PerfilAssinantes { get; set; } = null!;
    #endregion

    #region Media & System (Phase 8 - Fully Implemented)
    public DbSet<Imagem> Imagens { get; set; } = null!;
    public DbSet<Parametro> Parametros { get; set; } = null!;
    #endregion

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all Fluent API configurations from separate configuration classes
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(RdoDbContext).Assembly);
    }
}
