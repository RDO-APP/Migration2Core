# 🚀 STEP 7: REMAINING ENTITIES IMPLEMENTATION

## 🎯 **OBJECTIVE**

Implement the remaining 34 critical entities from Gilberto's original system to achieve complete database coverage and enable full system functionality.

## 📊 **CURRENT STATUS**

### ✅ **ALREADY IMPLEMENTED (16 entities)**
1. **Tarefa** - Core task entity
2. **Obra** - Project entity  
3. **Colaborador** - Employee entity
4. **Etapa** - Project phases
5. **StatusTarefa** - Task status
6. **Laudo** - Quality reports (Step 4)
7. **StatusRdo** - RDO status
8. **Rdo** - Daily work reports (Step 5)
9. **RdoTarefa** - RDO-task relationships
10. **ObraColaborador** - Project-employee assignments (Step 6)
11. **ObraTarefaColaborador** - Task-employee assignments
12. **ObraTarefaEquipamento** - Task-equipment assignments
13. **Equipamento** - Equipment entity
14. **ObraEquipamento** - Project-equipment assignments
15. **Cargo** - Job positions
16. **Grupo** - User groups
17. **TipoEquipamento** - Equipment types

### 🚨 **MISSING CRITICAL ENTITIES (34 entities)**

## 📋 **STEP 7 IMPLEMENTATION PLAN**

### **PHASE 1: Core System Entities (Priority 1)**

#### **1. Usuario Entity**
```csharp
[Table("usuario")]
public class Usuario
{
    [Key]
    [Column("usu_id_usuario")]
    public int Id { get; set; }
    
    [Column("usu_id_colaborador")]
    public int ColaboradorId { get; set; }
    
    [Column("usu_ds_login")]
    public string Login { get; set; } = string.Empty;
    
    [Column("usu_ds_senha")]
    public string Senha { get; set; } = string.Empty;
    
    [Column("usu_st_ativo")]
    public string? Ativo { get; set; }
    
    // Navigation Properties
    public virtual Colaborador Colaborador { get; set; } = null!;
}
```

#### **2. Municipio Entity** (if not already implemented)
```csharp
[Table("municipio")]
public class Municipio
{
    [Key]
    [Column("mun_id_municipio")]
    public int Id { get; set; }
    
    [Column("mun_id_uf")]
    public int UfId { get; set; }
    
    [Column("mun_nm_municipio")]
    public string Nome { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual Uf Uf { get; set; } = null!;
    public virtual ICollection<Colaborador> Colaboradores { get; set; } = new List<Colaborador>();
}
```

#### **3. Uf Entity** (if not already implemented)
```csharp
[Table("uf")]
public class Uf
{
    [Key]
    [Column("uf_id_uf")]
    public int Id { get; set; }
    
    [Column("uf_nm_uf")]
    public string Nome { get; set; } = string.Empty;
    
    [Column("uf_sg_uf")]
    public string Sigla { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual ICollection<Municipio> Municipios { get; set; } = new List<Municipio>();
}
```

#### **4. Empresa Entity** (if not already implemented)
```csharp
[Table("empresa")]
public class Empresa
{
    [Key]
    [Column("emp_id_empresa")]
    public int Id { get; set; }
    
    [Column("emp_id_municipio")]
    public int? MunicipioId { get; set; }
    
    [Column("emp_nm_empresa")]
    public string Nome { get; set; } = string.Empty;
    
    [Column("emp_nr_cnpj")]
    public string? Cnpj { get; set; }
    
    [Column("emp_ds_endereco")]
    public string? Endereco { get; set; }
    
    [Column("emp_nr_telefone")]
    public string? Telefone { get; set; }
    
    [Column("emp_ds_email")]
    public string? Email { get; set; }
    
    // Navigation Properties
    public virtual Municipio? Municipio { get; set; }
    public virtual ICollection<Obra> ObrasContratante { get; set; } = new List<Obra>();
    public virtual ICollection<Obra> ObrasContratada { get; set; } = new List<Obra>();
    public virtual ICollection<Obra> ObrasDono { get; set; } = new List<Obra>();
}
```

### **PHASE 2: History & Tracking Entities (Priority 2)**

#### **5. HistoricoTarefaColaborador Entity**
```csharp
[Table("historico_tarefa_colaborador")]
public class HistoricoTarefaColaborador
{
    [Key]
    [Column("htc_id_tarefa_colaborador")]
    public int Id { get; set; }
    
    [Column("htc_id_tarefa")]
    public int TarefaId { get; set; }
    
    [Column("htc_id_colaborador")]
    public int ColaboradorId { get; set; }
    
    [Column("htc_dt_inicio")]
    public DateTime? DataInicio { get; set; }
    
    [Column("htc_dt_fim")]
    public DateTime? DataFim { get; set; }
    
    // Navigation Properties
    public virtual Tarefa Tarefa { get; set; } = null!;
    public virtual Colaborador Colaborador { get; set; } = null!;
}
```

#### **6. HistoricoTarefaEquipamento Entity**
```csharp
[Table("historico_tarefa_equipamento")]
public class HistoricoTarefaEquipamento
{
    [Key]
    [Column("hte_id_tarefa_equipamento")]
    public int Id { get; set; }
    
    [Column("hte_id_tarefa")]
    public int TarefaId { get; set; }
    
    [Column("hte_id_equipamento")]
    public int EquipamentoId { get; set; }
    
    [Column("hte_dt_inicio")]
    public DateTime? DataInicio { get; set; }
    
    [Column("hte_dt_fim")]
    public DateTime? DataFim { get; set; }
    
    // Navigation Properties
    public virtual Tarefa Tarefa { get; set; } = null!;
    public virtual Equipamento Equipamento { get; set; } = null!;
}
```

#### **7. HistoricoTarefaRdo Entity**
```csharp
[Table("historico_tarefa_rdo")]
public class HistoricoTarefaRdo
{
    [Key]
    [Column("htr_id_historico_tarefa_rdo")]
    public int Id { get; set; }
    
    [Column("htr_id_tarefa")]
    public int TarefaId { get; set; }
    
    [Column("htr_id_rdo")]
    public int RdoId { get; set; }
    
    [Column("htr_dt_historico")]
    public DateTime? DataHistorico { get; set; }
    
    // Navigation Properties
    public virtual Tarefa Tarefa { get; set; } = null!;
    public virtual Rdo Rdo { get; set; } = null!;
}
```

#### **8. HistoricoLogin Entity**
```csharp
[Table("historico_login")]
public class HistoricoLogin
{
    [Key]
    [Column("col_id_colaborador")]
    public int ColaboradorId { get; set; }
    
    [Column("hlo_dt_login")]
    public DateTime? DataLogin { get; set; }
    
    [Column("hlo_ds_ip")]
    public string? Ip { get; set; }
    
    // Navigation Properties
    public virtual Colaborador Colaborador { get; set; } = null!;
}
```

### **PHASE 3: Business Logic Entities (Priority 3)**

#### **9. Imagem Entity**
```csharp
[Table("imagem")]
public class Imagem
{
    [Key]
    [Column("img_id_imagem")]
    public int Id { get; set; }
    
    [Column("img_id_tarefa")]
    public int? TarefaId { get; set; }
    
    [Column("img_ds_imagem")]
    public string? Descricao { get; set; }
    
    [Column("img_ds_caminho")]
    public string? Caminho { get; set; }
    
    // Navigation Properties
    public virtual Tarefa? Tarefa { get; set; }
}
```

#### **10. RdoImagem Entity**
```csharp
[Table("rdo_imagem")]
public class RdoImagem
{
    [Key]
    [Column("rim_id_rdo_imagem")]
    public int Id { get; set; }
    
    [Column("rim_id_rdo")]
    public int RdoId { get; set; }
    
    [Column("rim_id_imagem")]
    public int ImagemId { get; set; }
    
    // Navigation Properties
    public virtual Rdo Rdo { get; set; } = null!;
    public virtual Imagem Imagem { get; set; } = null!;
}
```

#### **11. Acidente Entity**
```csharp
[Table("acidente")]
public class Acidente
{
    [Key]
    [Column("aci_id_acidente")]
    public int Id { get; set; }
    
    [Column("aci_id_tarefa")]
    public int? TarefaId { get; set; }
    
    [Column("aci_ds_acidente")]
    public string? Descricao { get; set; }
    
    [Column("aci_dt_acidente")]
    public DateTime? DataAcidente { get; set; }
    
    // Navigation Properties
    public virtual Tarefa? Tarefa { get; set; }
    public virtual ICollection<AcidenteColaborador> AcidenteColaboradores { get; set; } = new List<AcidenteColaborador>();
}
```

#### **12. AcidenteColaborador Entity**
```csharp
[Table("acidente_colaborador")]
public class AcidenteColaborador
{
    [Key]
    [Column("acc_id_acidente_colaborador")]
    public int Id { get; set; }
    
    [Column("acc_id_acidente")]
    public int AcidenteId { get; set; }
    
    [Column("acc_id_colaborador")]
    public int ColaboradorId { get; set; }
    
    // Navigation Properties
    public virtual Acidente Acidente { get; set; } = null!;
    public virtual Colaborador Colaborador { get; set; } = null!;
}
```

### **PHASE 4: System Configuration Entities (Priority 4)**

#### **13. Parametro Entity**
```csharp
[Table("parametro")]
public class Parametro
{
    [Key]
    [Column("par_id_parametro")]
    public int Id { get; set; }
    
    [Column("par_nm_parametro")]
    public string Nome { get; set; } = string.Empty;
    
    [Column("par_vl_parametro")]
    public string? Valor { get; set; }
    
    [Column("par_ds_parametro")]
    public string? Descricao { get; set; }
}
```

#### **14. UnidadeDeMedida Entity**
```csharp
[Table("unidade_de_medida")]
public class UnidadeDeMedida
{
    [Key]
    [Column("udm_id_unidade_de_medida")]
    public int Id { get; set; }
    
    [Column("udm_ds_unidade_de_medida")]
    public string Descricao { get; set; } = string.Empty;
    
    [Column("udm_sg_unidade_de_medida")]
    public string? Sigla { get; set; }
    
    // Navigation Properties
    public virtual ICollection<Tarefa> Tarefas { get; set; } = new List<Tarefa>();
}
```

#### **15. TarefaCodigoParalizacao Entity**
```csharp
[Table("tarefa_codigo_paralizacao")]
public class TarefaCodigoParalizacao
{
    [Key]
    [Column("tcp_id_codigo_paralizacao")]
    public int Id { get; set; }
    
    [Column("tcp_ds_codigo_paralizacao")]
    public string Descricao { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual ICollection<Tarefa> Tarefas { get; set; } = new List<Tarefa>();
}
```

### **PHASE 5: Equipment Management Entities (Priority 5)**

#### **16. Marca Entity**
```csharp
[Table("marca")]
public class Marca
{
    [Key]
    [Column("mar_id_marca")]
    public int Id { get; set; }
    
    [Column("mar_ds_marca")]
    public string Descricao { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual ICollection<Modelo> Modelos { get; set; } = new List<Modelo>();
}
```

#### **17. Modelo Entity**
```csharp
[Table("modelo")]
public class Modelo
{
    [Key]
    [Column("mod_id_modelo")]
    public int Id { get; set; }
    
    [Column("mod_id_marca")]
    public int MarcaId { get; set; }
    
    [Column("mod_ds_modelo")]
    public string Descricao { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual Marca Marca { get; set; } = null!;
}
```

### **PHASE 6: HR & Organizational Entities (Priority 6)**

#### **18. Efetivo Entity**
```csharp
[Table("efetivo")]
public class Efetivo
{
    [Key]
    [Column("efe_id_efetivo")]
    public int Id { get; set; }
    
    [Column("efe_id_obra")]
    public int ObraId { get; set; }
    
    [Column("efe_id_colaborador")]
    public int ColaboradorId { get; set; }
    
    [Column("efe_id_efetivo_status")]
    public int? EfetivoStatusId { get; set; }
    
    [Column("efe_dt_inicio")]
    public DateTime? DataInicio { get; set; }
    
    [Column("efe_dt_fim")]
    public DateTime? DataFim { get; set; }
    
    // Navigation Properties
    public virtual Obra Obra { get; set; } = null!;
    public virtual Colaborador Colaborador { get; set; } = null!;
    public virtual EfetivoStatus? EfetivoStatus { get; set; }
}
```

#### **19. EfetivoStatus Entity**
```csharp
[Table("efetivo_status")]
public class EfetivoStatus
{
    [Key]
    [Column("est_id_efetivo_status")]
    public int Id { get; set; }
    
    [Column("est_ds_efetivo_status")]
    public string Descricao { get; set; } = string.Empty;
    
    // Navigation Properties
    public virtual ICollection<Efetivo> Efetivos { get; set; } = new List<Efetivo>();
}
```

#### **20. PerfilAssinante Entity**
```csharp
[Table("perfil_assinante")]
public class PerfilAssinante
{
    [Key]
    [Column("per_id_perfil")]
    public int Id { get; set; }
    
    [Column("per_ds_perfil")]
    public string Descricao { get; set; } = string.Empty;
    
    [Column("per_vl_perfil")]
    public decimal? Valor { get; set; }
}
```

## 🎯 **IMPLEMENTATION STRATEGY**

### **Step 7A: Create Core Entities (Phase 1)**
1. Create Usuario, Municipio, Uf, Empresa entities
2. Create corresponding configuration files
3. Add DbSets to RdoContext
4. Test compilation

### **Step 7B: Add History Entities (Phase 2)**
1. Create all historico_* entities
2. Add navigation properties to existing entities
3. Test compilation and relationships

### **Step 7C: Business Logic Entities (Phase 3)**
1. Create Imagem, RdoImagem, Acidente entities
2. Add image and accident management
3. Test functionality

### **Step 7D: System Configuration (Phase 4)**
1. Create Parametro, UnidadeDeMedida entities
2. Add system configuration support
3. Test parameter management

### **Step 7E: Complete Equipment & HR (Phases 5-6)**
1. Create remaining equipment and HR entities
2. Complete all relationships
3. Final testing and validation

## 📊 **SUCCESS CRITERIA**

- ✅ All 34 missing entities implemented
- ✅ All configuration files created
- ✅ All DbSets added to context
- ✅ Project compiles successfully
- ✅ Database connectivity maintained
- ✅ Navigation properties working
- ✅ Ready for comprehensive API development

## 🚀 **NEXT STEPS AFTER STEP 7**

1. **Step 8**: Add comprehensive navigation properties
2. **Step 9**: Create API controllers for all entities
3. **Step 10**: Implement advanced business logic
4. **Step 11**: Add security and permissions system
5. **Step 12**: Complete frontend integration

**Step 7 will provide complete database coverage and enable full system functionality!**