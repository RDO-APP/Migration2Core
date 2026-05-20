using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class HistoricoTarefaEquipamentoConfiguration : IEntityTypeConfiguration<HistoricoTarefaEquipamento>
{
    public void Configure(EntityTypeBuilder<HistoricoTarefaEquipamento> builder)
    {
        builder.ToTable("historico_tarefa_equipamento");
        builder.HasKey(e => e.HteIdTarefaEquipamento);
        builder.Property(e => e.HteIdTarefaEquipamento).HasColumnName("hte_id_tarefa_equipamento").ValueGeneratedOnAdd();
        builder.Property(e => e.HteIdHistoricoTarefaRdo).HasColumnName("hte_id_historico_tarefa_rdo").IsRequired();
        builder.Property(e => e.HteIdObraEquipamento).HasColumnName("hte_id_obra_equipamento").IsRequired();
        
        builder.HasIndex(e => e.HteIdHistoricoTarefaRdo).HasDatabaseName("IX_historico_tarefa_equipamento_historico");
        builder.HasIndex(e => e.HteIdObraEquipamento).HasDatabaseName("IX_historico_tarefa_equipamento_obra_equipamento");
    }
}
