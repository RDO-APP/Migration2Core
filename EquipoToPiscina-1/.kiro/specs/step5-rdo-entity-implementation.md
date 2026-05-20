# 📋 STEP 5: RDO Entity Implementation (Core Business Logic)

## 🎯 **OBJECTIVE**

Implement the **RDO (Relatório Diário de Obra)** entity - the core business entity for daily work reports in the pool management system. This is essential for tracking daily activities, work progress, and connecting tasks to daily operations.

## 📊 **BUSINESS CONTEXT**

**RDO** = "Relatório Diário de Obra" (Daily Work Report)
- **Core Purpose**: Track daily work activities on construction projects
- **Business Critical**: Central entity that connects projects, tasks, employees, and equipment
- **Day 9 Dependency**: Required for complete pool management workflow

## 🏗️ **IMPLEMENTATION REQUIREMENTS**

### **1. RDO Entity Structure**

Based on database analysis and Gilberto's original architecture:

```csharp
[Table("rdo")]
public class Rdo
{
    // Primary Key
    [Key]
    [Column("rdo_id_rdo")]
    public int Id { get; set; }
    
    // Foreign Keys
    [Column("rdo_id_obra")]
    public int ObraId { get; set; }
    
    [Column("rdo_id_colaborador")]
    public int? ColaboradorId { get; set; }
    
    // Core Fields
    [Column("rdo_dt_data")]
    public DateTime Data { get; set; }
    
    [Column("rdo_ds_observacao")]
    public string? Observacao { get; set; }
    
    [Column("rdo_nr_temperatura")]
    public decimal? Temperatura { get; set; }
    
    [Column("rdo_ds_condicoes_tempo")]
    public string? CondicoesTempo { get; set; }
    
    // Status and Control
    [Column("rdo_st_status")]
    public string? Status { get; set; }
    
    [Column("rdo_dt_criacao")]
    public DateTime DataCriacao { get; set; }
    
    [Column("rdo_dt_atualizacao")]
    public DateTime? DataAtualizacao { get; set; }
    
    // Navigation Properties
    public virtual Obra? Obra { get; set; }
    public virtual Colaborador? Colaborador { get; set; }
    public virtual ICollection<RdoTarefa>? RdoTarefas { get; set; }
}
```

### **2. RdoTarefa Relationship Entity**

```csharp
[Table("rdo_tarefa")]
public class RdoTarefa
{
    [Key]
    [Column("rdt_id_rdo_tarefa")]
    public int Id { get; set; }
    
    [Column("rdt_id_rdo")]
    public int RdoId { get; set; }
    
    [Column("rdt_id_tarefa")]
    public int TarefaId { get; set; }
    
    [Column("rdt_dt_inicio")]
    public DateTime? DataInicio { get; set; }
    
    [Column("rdt_dt_fim")]
    public DateTime? DataFim { get; set; }
    
    [Column("rdt_ds_observacao")]
    public string? Observacao { get; set; }
    
    // Navigation Properties
    public virtual Rdo? Rdo { get; set; }
    public virtual Tarefa? Tarefa { get; set; }
}
```

### **3. Fluent API Configurations**

#### **RdoConfiguration.cs**
```csharp
public class RdoConfiguration : IEntityTypeConfiguration<Rdo>
{
    public void Configure(EntityTypeBuilder<Rdo> builder)
    {
        builder.ToTable("rdo");
        
        builder.HasKey(r => r.Id);
        
        builder.Property(r => r.Id)
            .HasColumnName("rdo_id_rdo")
            .ValueGeneratedOnAdd();
            
        builder.Property(r => r.ObraId)
            .HasColumnName("rdo_id_obra")
            .IsRequired();
            
        builder.Property(r => r.ColaboradorId)
            .HasColumnName("rdo_id_colaborador");
            
        builder.Property(r => r.Data)
            .HasColumnName("rdo_dt_data")
            .IsRequired();
            
        builder.Property(r => r.Observacao)
            .HasColumnName("rdo_ds_observacao")
            .HasMaxLength(1000);
            
        builder.Property(r => r.Temperatura)
            .HasColumnName("rdo_nr_temperatura")
            .HasPrecision(5, 2);
            
        builder.Property(r => r.CondicoesTempo)
            .HasColumnName("rdo_ds_condicoes_tempo")
            .HasMaxLength(200);
            
        builder.Property(r => r.Status)
            .HasColumnName("rdo_st_status")
            .HasMaxLength(20);
            
        builder.Property(r => r.DataCriacao)
            .HasColumnName("rdo_dt_criacao")
            .IsRequired();
            
        builder.Property(r => r.DataAtualizacao)
            .HasColumnName("rdo_dt_atualizacao");
        
        // Relationships
        builder.HasOne(r => r.Obra)
            .WithMany()
            .HasForeignKey(r => r.ObraId)
            .OnDelete(DeleteBehavior.Restrict);
            
        builder.HasOne(r => r.Colaborador)
            .WithMany()
            .HasForeignKey(r => r.ColaboradorId)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasMany(r => r.RdoTarefas)
            .WithOne(rt => rt.Rdo)
            .HasForeignKey(rt => rt.RdoId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

#### **RdoTarefaConfiguration.cs**
```csharp
public class RdoTarefaConfiguration : IEntityTypeConfiguration<RdoTarefa>
{
    public void Configure(EntityTypeBuilder<RdoTarefa> builder)
    {
        builder.ToTable("rdo_tarefa");
        
        builder.HasKey(rt => rt.Id);
        
        builder.Property(rt => rt.Id)
            .HasColumnName("rdt_id_rdo_tarefa")
            .ValueGeneratedOnAdd();
            
        builder.Property(rt => rt.RdoId)
            .HasColumnName("rdt_id_rdo")
            .IsRequired();
            
        builder.Property(rt => rt.TarefaId)
            .HasColumnName("rdt_id_tarefa")
            .IsRequired();
            
        builder.Property(rt => rt.DataInicio)
            .HasColumnName("rdt_dt_inicio");
            
        builder.Property(rt => rt.DataFim)
            .HasColumnName("rdt_dt_fim");
            
        builder.Property(rt => rt.Observacao)
            .HasColumnName("rdt_ds_observacao")
            .HasMaxLength(500);
        
        // Relationships
        builder.HasOne(rt => rt.Rdo)
            .WithMany(r => r.RdoTarefas)
            .HasForeignKey(rt => rt.RdoId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasOne(rt => rt.Tarefa)
            .WithMany()
            .HasForeignKey(rt => rt.TarefaId)
            .OnDelete(DeleteBehavior.Restrict);
            
        // Unique constraint
        builder.HasIndex(rt => new { rt.RdoId, rt.TarefaId })
            .IsUnique();
    }
}
```

### **4. Service Layer**

#### **IRdoService Interface**
```csharp
public interface IRdoService
{
    Task<IEnumerable<RdoDto>> GetAllAsync();
    Task<RdoDto?> GetByIdAsync(int id);
    Task<IEnumerable<RdoDto>> GetByObraIdAsync(int obraId);
    Task<IEnumerable<RdoDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate);
    Task<RdoDto> CreateAsync(CreateRdoDto createDto);
    Task<RdoDto?> UpdateAsync(int id, UpdateRdoDto updateDto);
    Task<bool> DeleteAsync(int id);
    Task<bool> ExistsAsync(int obraId, DateTime data);
}
```

#### **RdoService Implementation**
```csharp
public class RdoService : IRdoService
{
    private readonly RdoContext _context;
    
    public RdoService(RdoContext context)
    {
        _context = context;
    }
    
    public async Task<IEnumerable<RdoDto>> GetAllAsync()
    {
        return await _context.Rdos
            .Include(r => r.Obra)
            .Include(r => r.Colaborador)
            .Include(r => r.RdoTarefas)
                .ThenInclude(rt => rt.Tarefa)
            .Select(r => new RdoDto
            {
                Id = r.Id,
                ObraId = r.ObraId,
                ColaboradorId = r.ColaboradorId,
                Data = r.Data,
                Observacao = r.Observacao,
                Temperatura = r.Temperatura,
                CondicoesTempo = r.CondicoesTempo,
                Status = r.Status,
                DataCriacao = r.DataCriacao,
                DataAtualizacao = r.DataAtualizacao,
                ObraNome = r.Obra != null ? r.Obra.Nome : null,
                ColaboradorNome = r.Colaborador != null ? r.Colaborador.Nome : null,
                TotalTarefas = r.RdoTarefas != null ? r.RdoTarefas.Count : 0
            })
            .ToListAsync();
    }
    
    // ... implement all other methods
}
```

### **5. API Controller**

#### **RdoController**
```csharp
[ApiController]
[Route("api/[controller]")]
public class RdoController : ControllerBase
{
    private readonly IRdoService _rdoService;
    
    public RdoController(IRdoService rdoService)
    {
        _rdoService = rdoService;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RdoDto>>> GetAll()
    {
        var rdos = await _rdoService.GetAllAsync();
        return Ok(rdos);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<RdoDto>> GetById(int id)
    {
        var rdo = await _rdoService.GetByIdAsync(id);
        if (rdo == null)
            return NotFound();
        return Ok(rdo);
    }
    
    [HttpGet("obra/{obraId}")]
    public async Task<ActionResult<IEnumerable<RdoDto>>> GetByObra(int obraId)
    {
        var rdos = await _rdoService.GetByObraIdAsync(obraId);
        return Ok(rdos);
    }
    
    [HttpGet("daterange")]
    public async Task<ActionResult<IEnumerable<RdoDto>>> GetByDateRange(
        [FromQuery] DateTime startDate, 
        [FromQuery] DateTime endDate)
    {
        var rdos = await _rdoService.GetByDateRangeAsync(startDate, endDate);
        return Ok(rdos);
    }
    
    [HttpPost]
    public async Task<ActionResult<RdoDto>> Create(CreateRdoDto createDto)
    {
        var rdo = await _rdoService.CreateAsync(createDto);
        return CreatedAtAction(nameof(GetById), new { id = rdo.Id }, rdo);
    }
    
    [HttpPut("{id}")]
    public async Task<ActionResult<RdoDto>> Update(int id, UpdateRdoDto updateDto)
    {
        var rdo = await _rdoService.UpdateAsync(id, updateDto);
        if (rdo == null)
            return NotFound();
        return Ok(rdo);
    }
    
    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var success = await _rdoService.DeleteAsync(id);
        if (!success)
            return NotFound();
        return NoContent();
    }
    
    [HttpGet("exists")]
    public async Task<ActionResult<bool>> Exists([FromQuery] int obraId, [FromQuery] DateTime data)
    {
        var exists = await _rdoService.ExistsAsync(obraId, data);
        return Ok(exists);
    }
}
```

### **6. Data Transfer Objects**

#### **RdoDto**
```csharp
public class RdoDto
{
    public int Id { get; set; }
    public int ObraId { get; set; }
    public int? ColaboradorId { get; set; }
    public DateTime Data { get; set; }
    public string? Observacao { get; set; }
    public decimal? Temperatura { get; set; }
    public string? CondicoesTempo { get; set; }
    public string? Status { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
    
    // Navigation Properties
    public string? ObraNome { get; set; }
    public string? ColaboradorNome { get; set; }
    public int TotalTarefas { get; set; }
}
```

#### **CreateRdoDto**
```csharp
public class CreateRdoDto
{
    [Required]
    public int ObraId { get; set; }
    
    public int? ColaboradorId { get; set; }
    
    [Required]
    public DateTime Data { get; set; }
    
    [MaxLength(1000)]
    public string? Observacao { get; set; }
    
    [Range(-50, 60)]
    public decimal? Temperatura { get; set; }
    
    [MaxLength(200)]
    public string? CondicoesTempo { get; set; }
    
    [MaxLength(20)]
    public string? Status { get; set; }
}
```

#### **UpdateRdoDto**
```csharp
public class UpdateRdoDto
{
    public int? ColaboradorId { get; set; }
    
    [MaxLength(1000)]
    public string? Observacao { get; set; }
    
    [Range(-50, 60)]
    public decimal? Temperatura { get; set; }
    
    [MaxLength(200)]
    public string? CondicoesTempo { get; set; }
    
    [MaxLength(20)]
    public string? Status { get; set; }
}
```

## 🔧 **INTEGRATION REQUIREMENTS**

### **1. Update RdoContext**
```csharp
// Add to RdoContext.cs
public DbSet<Rdo> Rdos { get; set; }
public DbSet<RdoTarefa> RdoTarefas { get; set; }
```

### **2. Register Services**
```csharp
// Add to Program.cs
builder.Services.AddScoped<IRdoService, RdoService>();
```

### **3. Update Navigation Properties**

#### **In Obra Entity**
```csharp
public virtual ICollection<Rdo>? Rdos { get; set; }
```

#### **In Colaborador Entity**
```csharp
public virtual ICollection<Rdo>? Rdos { get; set; }
```

#### **In Tarefa Entity**
```csharp
public virtual ICollection<RdoTarefa>? RdoTarefas { get; set; }
```

## ✅ **ACCEPTANCE CRITERIA**

### **1. Entity Implementation**
- [ ] Rdo entity created with all required fields
- [ ] RdoTarefa relationship entity created
- [ ] Fluent API configurations implemented
- [ ] Navigation properties added to related entities

### **2. Service Layer**
- [ ] IRdoService interface defined with 8 methods
- [ ] RdoService implementation with full CRUD operations
- [ ] Business validation (duplicate prevention, date validation)
- [ ] Entity Framework relationships with Include() statements

### **3. API Controller**
- [ ] RdoController with 8 REST endpoints
- [ ] Proper HTTP status codes and responses
- [ ] Input validation and error handling
- [ ] Swagger documentation

### **4. Data Transfer Objects**
- [ ] RdoDto for responses
- [ ] CreateRdoDto for creation
- [ ] UpdateRdoDto for updates
- [ ] Proper validation attributes

### **5. Database Integration**
- [ ] DbSets added to RdoContext
- [ ] Services registered in Program.cs
- [ ] Project compiles without errors
- [ ] Database connectivity verified

### **6. Testing**
- [ ] All API endpoints functional
- [ ] CRUD operations working
- [ ] Relationships properly loaded
- [ ] Business validation working

## 🎯 **BUSINESS IMPACT**

1. **Core Functionality**: RDO is the central entity for daily work tracking
2. **Day 9 Preparation**: Essential for complete pool management workflow
3. **Task Integration**: Links tasks to daily work reports
4. **Project Management**: Tracks daily progress on construction projects
5. **Reporting Foundation**: Enables comprehensive work reporting
6. **Audit Trail**: Provides complete history of daily activities

## 📋 **IMPLEMENTATION STEPS**

1. **Create Entities**: Rdo and RdoTarefa classes
2. **Create Configurations**: Fluent API mappings
3. **Create DTOs**: Request/response objects
4. **Create Service**: Business logic layer
5. **Create Controller**: API endpoints
6. **Update Context**: Add DbSets and registrations
7. **Update Related Entities**: Add navigation properties
8. **Test Implementation**: Verify all functionality

---

## 🚀 **READY FOR IMPLEMENTATION**

This specification provides complete implementation details for the RDO entity system. Once implemented, this will provide the core business logic for daily work report management in the pool construction system.

**Next Step**: Execute implementation following this specification.