using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Context
{
    public class RdoContext : DbContext
    {
        public RdoContext(DbContextOptions<RdoContext> options) : base(options)
        {
        }

        // DbSets principais - usando nomes corretos das tabelas do banco antigo
        public DbSet<Tarefa> Tarefas { get; set; }
        public DbSet<Obra> Obras { get; set; }
        public DbSet<Colaborador> Colaboradores { get; set; }
        public DbSet<Etapa> Etapas { get; set; }
        public DbSet<StatusTarefa> StatusTarefas { get; set; }

        // Step 4 - Laudo Entity Implementation (Critical for Day 9)
        public DbSet<Laudo> Laudos { get; set; }
        public DbSet<StatusRdo> StatusRdos { get; set; }

        // Step 5 - RDO Entity Implementation (Core Business Logic)
        public DbSet<Rdo> Rdos { get; set; }
        public DbSet<RdoTarefa> RdoTarefas { get; set; }

        // Step 6 - Relationship Entities (Activated for Complex Queries)
        public DbSet<ObraColaborador> ObraColaboradores { get; set; }
        public DbSet<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; }
        public DbSet<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; }
        public DbSet<Equipamento> Equipamentos { get; set; }
        public DbSet<ObraEquipamento> ObraEquipamentos { get; set; }
        public DbSet<Cargo> Cargos { get; set; }
        public DbSet<Grupo> Grupos { get; set; }
        public DbSet<TipoEquipamento> TipoEquipamentos { get; set; }

        // Step 7 - Core System Entities (Complete Database Coverage)
        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Municipio> Municipios { get; set; }
        public DbSet<Uf> Ufs { get; set; }
        public DbSet<Empresa> Empresas { get; set; }
        public DbSet<Ramo> Ramos { get; set; }
        public DbSet<Setor> Setores { get; set; }

        // Step 7 - History & Tracking Entities
        public DbSet<HistoricoTarefaColaborador> HistoricoTarefaColaboradores { get; set; }
        public DbSet<HistoricoTarefaEquipamento> HistoricoTarefaEquipamentos { get; set; }
        public DbSet<HistoricoTarefaRdo> HistoricoTarefaRdos { get; set; }
        public DbSet<HistoricoLogin> HistoricoLogins { get; set; }

        // Step 7 - Business Logic Entities
        public DbSet<Imagem> Imagens { get; set; }
        public DbSet<RdoImagem> RdoImagens { get; set; }
        public DbSet<Acidente> Acidentes { get; set; }
        public DbSet<AcidenteColaborador> AcidenteColaboradores { get; set; }

        // Step 7 - System Configuration Entities
        public DbSet<Parametro> Parametros { get; set; }
        public DbSet<UnidadeDeMedida> UnidadesDeMedida { get; set; }
        public DbSet<TarefaCodigoParalizacao> TarefaCodigoParalizacoes { get; set; }
        public DbSet<Improdutividade> Improdutividades { get; set; }
        public DbSet<AssinaturaRdo> AssinaturaRdos { get; set; }

        // Complete 48 Entities - Security System (RBAC)
        public DbSet<Acao> Acoes { get; set; }
        public DbSet<Pagina> Paginas { get; set; }
        public DbSet<PaginaAcao> PaginaAcoes { get; set; }
        public DbSet<GrupoPaginaAcao> GrupoPaginaAcoes { get; set; }
        public DbSet<Menu> Menus { get; set; }
        public DbSet<MenuPagina> MenuPaginas { get; set; }
        public DbSet<PerfilAssinante> PerfilAssinantes { get; set; }

        // Complete 48 Entities - Equipment Management
        public DbSet<Marca> Marcas { get; set; }
        public DbSet<Modelo> Modelos { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Aplicar configurações - Day 7 Implementation
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(RdoContext).Assembly);

            // Configurações globais para MySQL
            foreach (var entityType in modelBuilder.Model.GetEntityTypes())
            {
                // Configurar propriedades string como varchar por padrão
                foreach (var property in entityType.GetProperties())
                {
                    if (property.ClrType == typeof(string) && property.GetMaxLength() == null)
                    {
                        property.SetMaxLength(255);
                    }
                }
            }
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                // Banco ANTIGO com dados reais - Day 6 Fixed
                optionsBuilder.UseMySql(
                    "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;",
                    ServerVersion.Create(new Version(8, 0, 30), Pomelo.EntityFrameworkCore.MySql.Infrastructure.ServerType.MySql)
                );
            }
        }
    }
}
