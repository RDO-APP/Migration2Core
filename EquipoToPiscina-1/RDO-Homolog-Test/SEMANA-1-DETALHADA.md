# SEMANA 1: PREPARAÇÃO E SETUP - DETALHADO DIA A DIA

## **DIA 1: SETUP DO AMBIENTE .NET 8** ⚙️

### **MANHÃ (09:00 - 13:00) - 4 HORAS**

#### **09:00 - 10:30: INSTALAÇÃO .NET 8 SDK**
```
1. BAIXAR .NET 8 SDK:
   - Ir para: https://dotnet.microsoft.com/download/dotnet/8.0
   - Baixar: .NET 8.0 SDK (x64) para Windows
   - Executar instalador
   - Reiniciar se necessário

2. VERIFICAR INSTALAÇÃO:
   - Abrir CMD ou PowerShell
   - Executar: dotnet --version
   - Deve mostrar: 8.0.x
   - Executar: dotnet --list-sdks
   - Confirmar que 8.0.x está listado
```

#### **10:30 - 12:00: ATUALIZAR VISUAL STUDIO 2022**
```
1. ABRIR VISUAL STUDIO INSTALLER:
   - Procurar "Visual Studio Installer" no menu iniciar
   - Clicar em "Modify" no VS Community 2022

2. INSTALAR WORKLOADS NECESSÁRIOS:
   ✅ ASP.NET and web development
   ✅ .NET desktop development
   ✅ Data storage and processing (para MySQL)

3. COMPONENTES INDIVIDUAIS (aba Individual components):
   ✅ .NET 8.0 Runtime (LTS)
   ✅ Entity Framework 8 tools
   ✅ NuGet package manager

4. APLICAR MODIFICAÇÕES:
   - Clicar "Modify"
   - Aguardar download e instalação (15-30 min)
   - Reiniciar Visual Studio
```

#### **12:00 - 13:00: VERIFICAR FERRAMENTAS**
```
1. TESTAR VISUAL STUDIO:
   - Abrir Visual Studio 2022
   - File > New > Project
   - Verificar se aparece ".NET 8.0" nas opções
   - Cancelar (não criar projeto ainda)

2. INSTALAR EXTENSÕES ÚTEIS:
   - Extensions > Manage Extensions
   - Instalar: "Entity Framework Visual Editor" (opcional)
   - Instalar: "MySQL for Visual Studio" (se disponível)

3. CONFIGURAR GIT (se não configurado):
   - git config --global user.name "Seu Nome"
   - git config --global user.email "seu@email.com"
```

### **TARDE (14:00 - 18:00) - 4 HORAS**

#### **14:00 - 15:30: CRIAR PROJETO BASE**
```
1. CRIAR NOVO PROJETO:
   - File > New > Project
   - Selecionar: "ASP.NET Core Web App (Model-View-Controller)"
   - Nome: "RdoApp.Core"
   - Location: Criar pasta "RDO-NET8-Migration"
   - Framework: ".NET 8.0 (Long Term Support)"
   - Authentication: None (configuraremos depois)
   - Configure for HTTPS: ✅ Checked
   - Enable Docker: ❌ Unchecked
   - Do not use top-level statements: ✅ Checked (mais familiar)

2. ESTRUTURA INICIAL CRIADA:
   RdoApp.Core/
   ├── Controllers/
   │   └── HomeController.cs
   ├── Models/
   ├── Views/
   │   ├── Home/
   │   └── Shared/
   ├── wwwroot/
   ├── Program.cs
   ├── appsettings.json
   └── RdoApp.Core.csproj
```

#### **15:30 - 16:30: CONFIGURAR GIT**
```
1. INICIALIZAR REPOSITÓRIO:
   - Abrir terminal no diretório do projeto
   - git init
   - git add .
   - git commit -m "Initial commit - .NET 8 project created"

2. CRIAR BRANCH DE MIGRAÇÃO:
   - git checkout -b dotnet8-migration
   - git push -u origin dotnet8-migration (se tiver remote)

3. CRIAR .gitignore ADEQUADO:
   - Usar template do Visual Studio para .NET
   - Adicionar linhas específicas:
     bin/
     obj/
     *.user
     appsettings.Development.json
     wwwroot/uploads/
```

#### **16:30 - 17:30: INSTALAR PACOTES NUGET ESSENCIAIS**
```
1. ENTITY FRAMEWORK CORE:
   - Tools > NuGet Package Manager > Package Manager Console
   - Install-Package Microsoft.EntityFrameworkCore
   - Install-Package Microsoft.EntityFrameworkCore.Tools
   - Install-Package Pomelo.EntityFrameworkCore.MySql

2. OUTROS PACOTES ESSENCIAIS:
   - Install-Package Microsoft.EntityFrameworkCore.Design
   - Install-Package Serilog.AspNetCore (logging)
   - Install-Package AutoMapper.Extensions.Microsoft.DependencyInjection

3. VERIFICAR INSTALAÇÃO:
   - Verificar RdoApp.Core.csproj
   - Confirmar que todos os pacotes estão listados
```

#### **17:30 - 18:00: TESTE INICIAL**
```
1. COMPILAR PROJETO:
   - Build > Build Solution
   - Verificar se compila sem erros
   - Resolver qualquer problema

2. EXECUTAR PROJETO:
   - Pressionar F5
   - Verificar se abre no navegador
   - Confirmar que página inicial carrega
   - Parar execução

3. DOCUMENTAR PROGRESSO:
   - Anotar versões instaladas
   - Listar pacotes NuGet
   - Commit das mudanças: git commit -m "Day 1: .NET 8 environment setup complete"
```

---

## **DIA 2: ESTRUTURA DE PASTAS E CONFIGURAÇÃO INICIAL** 📁

### **MANHÃ (09:00 - 13:00) - 4 HORAS**

#### **09:00 - 10:30: CRIAR ESTRUTURA DE PASTAS**
```
1. CRIAR PASTAS NO PROJETO:
   RdoApp.Core/
   ├── Controllers/
   │   ├── Api/          (para API controllers)
   │   └── Web/          (para MVC controllers)
   ├── Models/
   │   ├── Entities/     (entidades do banco)
   │   ├── ViewModels/   (view models)
   │   └── DTOs/         (data transfer objects)
   ├── Services/
   │   ├── Interfaces/   (contratos)
   │   └── Implementations/
   ├── Data/
   │   ├── Context/      (DbContext)
   │   ├── Configurations/ (entity configurations)
   │   └── Migrations/   (migrations EF)
   ├── Views/
   │   ├── Shared/
   │   ├── Home/
   │   ├── Tarefa/
   │   ├── Colaborador/
   │   └── Obra/
   └── wwwroot/
       ├── css/
       ├── js/
       ├── images/
       └── uploads/

2. CRIAR ARQUIVOS PLACEHOLDER:
   - Criar arquivo vazio .gitkeep em cada pasta
   - Isso mantém as pastas no Git
```

#### **10:30 - 12:00: CONFIGURAR Program.cs**
```
1. SUBSTITUIR CONTEÚDO DO Program.cs:

using Microsoft.EntityFrameworkCore;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configurar Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();

builder.Host.UseSerilog();

// Adicionar serviços
builder.Services.AddControllersWithViews();

// Entity Framework
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<RdoContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// AutoMapper
builder.Services.AddAutoMapper(typeof(Program));

// Serviços customizados (adicionaremos depois)
// builder.Services.AddScoped<ITarefaService, TarefaService>();

var app = builder.Build();

// Configure pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

// Rotas
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// API routes
app.MapControllerRoute(
    name: "api",
    pattern: "api/{controller}/{action=Index}/{id?}");

app.Run();

2. RESOLVER ERROS DE COMPILAÇÃO:
   - RdoContext ainda não existe (criaremos no próximo passo)
   - Comentar linha do DbContext temporariamente
```

#### **12:00 - 13:00: CONFIGURAR appsettings.json**
```
1. SUBSTITUIR appsettings.json:

{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=piscinas_rdoapp_homologa;Uid=root;Pwd=sua_senha_mysql;"
  },
  "Serilog": {
    "Using": ["Serilog.Sinks.Console", "Serilog.Sinks.File"],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    },
    "WriteTo": [
      {
        "Name": "Console"
      },
      {
        "Name": "File",
        "Args": {
          "path": "logs/log-.txt",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 7
        }
      }
    ]
  },
  "AllowedHosts": "*"
}

2. CRIAR appsettings.Development.json:

{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=piscinas_rdoapp_homologa;Uid=root;Pwd=sua_senha_mysql;"
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug"
    }
  }
}

3. AJUSTAR CONNECTION STRING:
   - Substituir "sua_senha_mysql" pela senha real
   - Testar conexão com MySQL Workbench ou DBeaver
```

### **TARDE (14:00 - 18:00) - 4 HORAS**

#### **14:00 - 15:30: CRIAR DbContext BÁSICO**
```
1. CRIAR Data/Context/RdoContext.cs:

using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Context
{
    public class RdoContext : DbContext
    {
        public RdoContext(DbContextOptions<RdoContext> options) : base(options)
        {
        }

        // DbSets principais (adicionaremos gradualmente)
        public DbSet<Tarefa> Tarefas { get; set; }
        public DbSet<Obra> Obras { get; set; }
        public DbSet<Colaborador> Colaboradores { get; set; }
        public DbSet<Etapa> Etapas { get; set; }
        public DbSet<StatusTarefa> StatusTarefas { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configurações serão adicionadas aqui
            // modelBuilder.ApplyConfigurationsFromAssembly(typeof(RdoContext).Assembly);
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                // Fallback connection string
                optionsBuilder.UseMySql(
                    "Server=localhost;Database=piscinas_rdoapp_homologa;Uid=root;Pwd=sua_senha;",
                    ServerVersion.AutoDetect("Server=localhost;Database=piscinas_rdoapp_homologa;Uid=root;Pwd=sua_senha;")
                );
            }
        }
    }
}

2. DESCOMENTAR LINHA NO Program.cs:
   - Descomentar a linha do AddDbContext
   - Adicionar using: using RdoApp.Core.Data.Context;
```

#### **15:30 - 17:00: CRIAR ENTIDADES BÁSICAS**
```
1. CRIAR Models/Entities/Tarefa.cs:

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("tarefa")]
    public class Tarefa
    {
        [Key]
        [Column("tar_id_tarefa")]
        public int Id { get; set; }

        [Column("tar_ds_tarefa")]
        [StringLength(500)]
        public string Descricao { get; set; } = string.Empty;

        [Column("tar_dt_inicio")]
        public DateTime DataInicio { get; set; }

        [Column("tar_dt_previsao_fim")]
        public DateTime? DataPrevisaoFim { get; set; }

        [Column("tar_id_status")]
        public int StatusId { get; set; }

        [Column("tar_id_etapa")]
        public int EtapaId { get; set; }

        [Column("tar_ds_comentario")]
        public string? Comentario { get; set; }

        [Column("tar_dt_insercao")]
        public DateTime DataInsercao { get; set; }

        [Column("tar_dt_ultima_atualizacao")]
        public DateTime? DataUltimaAtualizacao { get; set; }

        // Relacionamentos
        public virtual StatusTarefa Status { get; set; } = null!;
        public virtual Etapa Etapa { get; set; } = null!;
    }
}

2. CRIAR OUTRAS ENTIDADES BÁSICAS:
   - Models/Entities/Obra.cs
   - Models/Entities/Colaborador.cs  
   - Models/Entities/Etapa.cs
   - Models/Entities/StatusTarefa.cs

   (Usar estrutura similar, mapeando colunas do banco atual)
```

#### **17:00 - 18:00: TESTE DE CONEXÃO**
```
1. COMPILAR PROJETO:
   - Build > Build Solution
   - Resolver erros de compilação

2. TESTAR CONEXÃO COM BANCO:
   - Criar controller temporário para teste
   - Fazer query simples: context.Tarefas.Count()
   - Verificar se conecta sem erro

3. COMMIT DO PROGRESSO:
   - git add .
   - git commit -m "Day 2: Project structure and basic DbContext created"

4. DOCUMENTAR PROBLEMAS:
   - Anotar qualquer erro encontrado
   - Listar próximos passos
```

---

## **DIA 3: ENTITY FRAMEWORK CORE - CONFIGURAÇÃO** 🗄️

### **MANHÃ (09:00 - 13:00) - 4 HORAS**

#### **09:00 - 10:30: CONFIGURAÇÕES DE ENTIDADES**
```
1. CRIAR Data/Configurations/TarefaConfiguration.cs:

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class TarefaConfiguration : IEntityTypeConfiguration<Tarefa>
    {
        public void Configure(EntityTypeBuilder<Tarefa> builder)
        {
            builder.ToTable("tarefa");
            
            builder.HasKey(t => t.Id);
            
            builder.Property(t => t.Id)
                .HasColumnName("tar_id_tarefa")
                .ValueGeneratedOnAdd();

            builder.Property(t => t.Descricao)
                .HasColumnName("tar_ds_tarefa")
                .HasMaxLength(500)
                .IsRequired();

            builder.Property(t => t.DataInicio)
                .HasColumnName("tar_dt_inicio")
                .IsRequired();

            builder.Property(t => t.DataPrevisaoFim)
                .HasColumnName("tar_dt_previsao_fim");

            builder.Property(t => t.StatusId)
                .HasColumnName("tar_id_status")
                .IsRequired();

            builder.Property(t => t.EtapaId)
                .HasColumnName("tar_id_etapa")
                .IsRequired();

            builder.Property(t => t.Comentario)
                .HasColumnName("tar_ds_comentario")
                .HasMaxLength(1000);

            builder.Property(t => t.DataInsercao)
                .HasColumnName("tar_dt_insercao")
                .IsRequired();

            builder.Property(t => t.DataUltimaAtualizacao)
                .HasColumnName("tar_dt_ultima_atualizacao");

            // Relacionamentos
            builder.HasOne(t => t.Status)
                .WithMany()
                .HasForeignKey(t => t.StatusId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(t => t.Etapa)
                .WithMany()
                .HasForeignKey(t => t.EtapaId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}

2. CRIAR CONFIGURAÇÕES PARA OUTRAS ENTIDADES:
   - ObraConfiguration.cs
   - ColaboradorConfiguration.cs
   - EtapaConfiguration.cs
   - StatusTarefaConfiguration.cs
```

#### **10:30 - 12:00: APLICAR CONFIGURAÇÕES NO DbContext**
```
1. ATUALIZAR RdoContext.cs:

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    base.OnModelCreating(modelBuilder);

    // Aplicar todas as configurações
    modelBuilder.ApplyConfigurationsFromAssembly(typeof(RdoContext).Assembly);

    // Configurações globais
    foreach (var entityType in modelBuilder.Model.GetEntityTypes())
    {
        // Configurar nomes de tabelas em minúsculo
        entityType.SetTableName(entityType.GetTableName()?.ToLower());
        
        // Configurar propriedades string como varchar por padrão
        foreach (var property in entityType.GetProperties())
        {
            if (property.ClrType == typeof(string))
            {
                property.SetColumnType("varchar(255)");
            }
        }
    }
}

2. TESTAR CONFIGURAÇÕES:
   - Compilar projeto
   - Verificar se não há erros de mapeamento
```

#### **12:00 - 13:00: PRIMEIRA MIGRATION**
```
1. CRIAR MIGRATION INICIAL:
   - Abrir Package Manager Console
   - Add-Migration InitialCreate
   - Verificar arquivo de migration criado

2. ANALISAR MIGRATION:
   - Verificar se tabelas estão corretas
   - Confirmar nomes de colunas
   - Verificar tipos de dados

3. NÃO APLICAR AINDA:
   - Não executar Update-Database ainda
   - Primeiro vamos validar tudo
```

### **TARDE (14:00 - 18:00) - 4 HORAS**

#### **14:00 - 15:30: VALIDAR MAPEAMENTO COM BANCO EXISTENTE**
```
1. COMPARAR COM BANCO ATUAL:
   - Abrir DBeaver ou MySQL Workbench
   - Conectar em piscinas_rdoapp_homologa
   - Comparar estrutura da tabela 'tarefa' com nossa entidade

2. AJUSTAR MAPEAMENTOS:
   - Corrigir tipos de dados se necessário
   - Ajustar tamanhos de campos
   - Verificar campos nullable

3. ATUALIZAR ENTIDADES:
   - Fazer ajustes nas entidades conforme necessário
   - Recriar migration se houver mudanças significativas
```

#### **15:30 - 17:00: TESTAR CONEXÃO E QUERIES**
```
1. CRIAR CONTROLLER DE TESTE:

[ApiController]
[Route("api/[controller]")]
public class TesteController : ControllerBase
{
    private readonly RdoContext _context;

    public TesteController(RdoContext context)
    {
        _context = context;
    }

    [HttpGet("conexao")]
    public async Task<IActionResult> TestarConexao()
    {
        try
        {
            var count = await _context.Tarefas.CountAsync();
            return Ok(new { message = "Conexão OK", totalTarefas = count });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("tarefas")]
    public async Task<IActionResult> ListarTarefas()
    {
        try
        {
            var tarefas = await _context.Tarefas
                .Take(10)
                .Select(t => new { 
                    t.Id, 
                    t.Descricao, 
                    t.DataInicio 
                })
                .ToListAsync();
            
            return Ok(tarefas);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }
}

2. TESTAR ENDPOINTS:
   - Executar projeto (F5)
   - Testar: GET /api/teste/conexao
   - Testar: GET /api/teste/tarefas
   - Verificar se retorna dados do banco
```

#### **17:00 - 18:00: RESOLVER PROBLEMAS E DOCUMENTAR**
```
1. RESOLVER ERROS ENCONTRADOS:
   - Ajustar connection string se necessário
   - Corrigir mapeamentos problemáticos
   - Verificar permissões do banco

2. DOCUMENTAR PROGRESSO:
   - Anotar configurações que funcionaram
   - Listar problemas encontrados e soluções
   - Documentar estrutura de entidades

3. COMMIT DO DIA:
   - git add .
   - git commit -m "Day 3: Entity Framework Core configuration and basic entities"

4. PREPARAR PRÓXIMO DIA:
   - Listar entidades que faltam migrar
   - Identificar relacionamentos complexos
   - Planejar ordem de implementação
```

---

## **DIA 4: RELACIONAMENTOS E ENTIDADES COMPLEXAS** 🔗

### **MANHÃ (09:00 - 13:00) - 4 HORAS**

#### **09:00 - 10:30: MAPEAR RELACIONAMENTOS PRINCIPAIS**
```
1. ANALISAR RELACIONAMENTOS NO BANCO ATUAL:
   - Usar DBeaver para ver Foreign Keys
   - Identificar relacionamentos 1:N e N:N
   - Mapear dependências entre tabelas

2. PRINCIPAIS RELACIONAMENTOS IDENTIFICADOS:
   - Tarefa → Etapa → Obra
   - Tarefa → StatusTarefa
   - Obra → Colaborador (N:N via obra_colaborador)
   - Tarefa → Colaborador (N:N via obra_tarefa_colaborador)
   - Tarefa → Equipamento (N:N via obra_tarefa_equipamento)

3. CRIAR ENTIDADES DE RELACIONAMENTO:
   - Models/Entities/ObraColaborador.cs
   - Models/Entities/ObraTarefaColaborador.cs
   - Models/Entities/ObraTarefaEquipamento.cs
```

#### **10:30 - 12:00: IMPLEMENTAR ENTIDADES RELACIONAIS**
```
1. CRIAR ObraColaborador.cs:

[Table("obra_colaborador")]
public class ObraColaborador
{
    [Key]
    [Column("oco_id_obra_colaborador")]
    public int Id { get; set; }

    [Column("oco_id_obra")]
    public int ObraId { get; set; }

    [Column("oco_id_colaborador")]
    public int ColaboradorId { get; set; }

    [Column("oco_dt_insercao")]
    public DateTime DataInsercao { get; set; }

    // Relacionamentos
    public virtual Obra Obra { get; set; } = null!;
    public virtual Colaborador Colaborador { get; set; } = null!;
}

2. ATUALIZAR ENTIDADES PRINCIPAIS:
   - Adicionar navigation properties
   - Configurar relacionamentos bidirecionais
   - Usar ICollection<> para relacionamentos 1:N
```

#### **12:00 - 13:00: CONFIGURAR RELACIONAMENTOS NO DbContext**
```
1. ATUALIZAR CONFIGURAÇÕES:

// Em TarefaConfiguration.cs
builder.HasMany(t => t.Colaboradores)
    .WithMany(c => c.Tarefas)
    .UsingEntity<ObraTarefaColaborador>(
        j => j.HasOne(otc => otc.Colaborador)
              .WithMany()
              .HasForeignKey(otc => otc.ColaboradorId),
        j => j.HasOne(otc => otc.Tarefa)
              .WithMany()
              .HasForeignKey(otc => otc.TarefaId),
        j => j.ToTable("obra_tarefa_colaborador")
    );

2. ADICIONAR DbSets NO RdoContext:
   - public DbSet<ObraColaborador> ObraColaboradores { get; set; }
   - public DbSet<ObraTarefaColaborador> ObraTarefaColaboradores { get; set; }
   - public DbSet<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; }
```

### **TARDE (14:00 - 18:00) - 4 HORAS**

#### **14:00 - 15:30: ADICIONAR ENTIDADES RESTANTES**
```
1. CRIAR ENTIDADES IMPORTANTES:
   - Models/Entities/Equipamento.cs
   - Models/Entities/UnidadeMedida.cs
   - Models/Entities/Cargo.cs
   - Models/Entities/Grupo.cs
   - Models/Entities/Empresa.cs
   - Models/Entities/Licenca.cs

2. SEGUIR PADRÃO ESTABELECIDO:
   - Usar [Table] e [Column] attributes
   - Mapear todos os campos principais
   - Adicionar navigation properties
```

#### **15:30 - 17:00: ENTIDADE LAUDO (CRÍTICA)**
```
1. CRIAR Models/Entities/Laudo.cs:

[Table("laudo")]
public class Laudo
{
    [Key]
    [Column("lau_id_laudo")]
    public int Id { get; set; }

    [Column("lau_dt_laudo")]
    public DateTime DataLaudo { get; set; }

    [Column("lau_id_obra")]
    public int ObraId { get; set; }

    [Column("lau_id_colaborador")]
    public int ColaboradorId { get; set; }

    [Column("lau_dt_geracao")]
    public DateTime DataGeracao { get; set; }

    [Column("lau_id_status")]
    public int StatusId { get; set; }

    // Campos específicos do laudo (baseado no que implementamos)
    [Column("lau_tp_nivel_cloro")]
    public bool? NivelCloro { get; set; }

    [Column("lau_tp_ph")]
    public bool? NivelPH { get; set; }

    [Column("lau_tp_alcalinidade")]
    public int? NivelAlcalinidade { get; set; }

    [Column("lau_tp_limpidez")]
    public bool? Limpidez { get; set; }

    [Column("lau_tp_superficie")]
    public bool? Superficie { get; set; }

    [Column("lau_tp_fundo")]
    public bool? Fundo { get; set; }

    [Column("lau_tp_nivel_bacterias")]
    public bool? NivelBacterias { get; set; }

    [Column("lau_tp_nivel_proliferacao")]
    public bool? NivelProliferacao { get; set; }

    // Relacionamentos
    public virtual Obra Obra { get; set; } = null!;
    public virtual Colaborador Colaborador { get; set; } = null!;
}

2. CONFIGURAR RELACIONAMENTOS DO LAUDO:
   - Criar LaudoConfiguration.cs
   - Mapear relacionamentos com Obra e Colaborador
   - Adicionar ao DbContext
```

#### **17:00 - 18:00: TESTAR ENTIDADES COMPLEXAS**
```
1. ATUALIZAR CONTROLLER DE TESTE:

[HttpGet("relacionamentos")]
public async Task<IActionResult> TestarRelacionamentos()
{
    try
    {
        var tarefa = await _context.Tarefas
            .Include(t => t.Status)
            .Include(t => t.Etapa)
                .ThenInclude(e => e.Obra)
            .FirstOrDefaultAsync();

        if (tarefa == null)
            return NotFound("Nenhuma tarefa encontrada");

        return Ok(new {
            tarefa.Id,
            tarefa.Descricao,
            Status = tarefa.Status.Descricao,
            Etapa = tarefa.Etapa.Descricao,
            Obra = tarefa.Etapa.Obra.Descricao
        });
    }
    catch (Exception ex)
    {
        return BadRequest(new { error = ex.Message });
    }
}

2. TESTAR QUERIES COMPLEXAS:
   - Executar projeto
   - Testar endpoint de relacionamentos
   - Verificar se Include() funciona corretamente

3. COMMIT DO PROGRESSO:
   - git add .
   - git commit -m "Day 4: Complex entities and relationships implemented"
```

---

## **DIA 5: VALIDAÇÃO E TESTES FINAIS** ✅

### **MANHÃ (09:00 - 13:00) - 4 HORAS**

#### **09:00 - 10:30: MIGRATION FINAL E VALIDAÇÃO**
```
1. CRIAR MIGRATION COMPLETA:
   - Remove-Migration (se houver migration anterior)
   - Add-Migration CompleteEntityModel
   - Revisar arquivo de migration gerado

2. VALIDAR MIGRATION:
   - Verificar se todas as tabelas estão incluídas
   - Confirmar foreign keys
   - Verificar índices importantes

3. APLICAR MIGRATION (CUIDADO!):
   - Fazer backup do banco antes
   - Update-Database
   - Verificar se aplicou sem erros
```

#### **10:30 - 12:00: TESTES ABRANGENTES**
```
1. CRIAR TESTES PARA TODAS AS ENTIDADES:

[HttpGet("entidades")]
public async Task<IActionResult> TestarTodasEntidades()
{
    try
    {
        var resultado = new
        {
            Tarefas = await _context.Tarefas.CountAsync(),
            Obras = await _context.Obras.CountAsync(),
            Colaboradores = await _context.Colaboradores.CountAsync(),
            Etapas = await _context.Etapas.CountAsync(),
            StatusTarefas = await _context.StatusTarefas.CountAsync(),
            Laudos = await _context.Laudos.CountAsync(),
            ObraColaboradores = await _context.ObraColaboradores.CountAsync()
        };

        return Ok(resultado);
    }
    catch (Exception ex)
    {
        return BadRequest(new { error = ex.Message });
    }
}

2. TESTAR CRUD BÁSICO:
   - Criar endpoint para inserir tarefa teste
   - Testar update de tarefa
   - Testar delete (soft delete se aplicável)
```

#### **12:00 - 13:00: PERFORMANCE E OTIMIZAÇÃO**
```
1. TESTAR PERFORMANCE:
   - Queries com Include()
   - Queries com muitos dados
   - Verificar SQL gerado (logging)

2. OTIMIZAÇÕES INICIAIS:
   - Adicionar índices importantes
   - Configurar lazy loading (se necessário)
   - Ajustar connection pooling
```

### **TARDE (14:00 - 18:00) - 4 HORAS**

#### **14:00 - 15:30: DOCUMENTAÇÃO TÉCNICA**
```
1. CRIAR DOCUMENTAÇÃO DAS ENTIDADES:
   - Listar todas as entidades criadas
   - Documentar relacionamentos
   - Mapear campos importantes

2. DOCUMENTAR CONFIGURAÇÕES:
   - Connection strings
   - Configurações do EF Core
   - Pacotes NuGet utilizados
```

#### **15:30 - 17:00: PREPARAÇÃO PARA SEMANA 2**
```
1. ANÁLISE DO CÓDIGO ATUAL:
   - Revisar TarefaController.cs original
   - Identificar métodos principais
   - Mapear ViewModels necessários

2. PLANEJAR CONTROLLERS:
   - Listar controllers a migrar
   - Definir ordem de prioridade
   - Identificar dependências
```

#### **17:00 - 18:00: COMMIT FINAL E RETROSPECTIVA**
```
1. COMMIT FINAL DA SEMANA:
   - git add .
   - git commit -m "Week 1 complete: .NET 8 setup and Entity Framework Core ready"
   - git tag "week1-complete"

2. RETROSPECTIVA DA SEMANA:
   - Documentar o que funcionou bem
   - Listar problemas encontrados
   - Avaliar se cronograma está no prazo

3. PREPARAR SEMANA 2:
   - Revisar plano da Semana 2
   - Ajustar cronograma se necessário
   - Definir prioridades
```

---

## **RESUMO DA SEMANA 1** 📋

### **OBJETIVOS ALCANÇADOS:**
- ✅ .NET 8 SDK instalado e configurado
- ✅ Visual Studio 2022 atualizado
- ✅ Projeto ASP.NET Core 8 criado
- ✅ Entity Framework Core configurado
- ✅ Conexão com MySQL funcionando
- ✅ Entidades principais mapeadas
- ✅ Relacionamentos configurados
- ✅ Testes básicos funcionando

### **ENTREGÁVEIS:**
- Projeto RdoApp.Core funcional
- DbContext completo com 15+ entidades
- Migrations aplicadas
- Testes de conexão e CRUD
- Documentação técnica

### **PRÓXIMOS PASSOS (SEMANA 2):**
- Migrar Controllers principais
- Implementar ViewModels
- Configurar autenticação
- Criar APIs REST

### **RISCOS IDENTIFICADOS:**
- Relacionamentos complexos podem precisar ajustes
- Performance com muitas entidades
- Compatibilidade com dados existentes

**SEMANA 1 CONCLUÍDA COM SUCESSO! 🎉**