using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class HistoricoTarefaRdoConfiguration : IEntityTypeConfiguration<HistoricoTarefaRdo>
{
    public void Configure(EntityTypeBuilder<HistoricoTarefaRdo> builder)
    {
        builder.ToTable("historico_tarefa_rdo");
        builder.HasKey(e => e.HisIdHistoricoTarefaRdo);
        builder.Property(e => e.HisIdHistoricoTarefaRdo).HasColumnName("his_id_historico_tarefa_rdo").ValueGeneratedOnAdd();
        builder.Property(e => e.HisIdTarefa).HasColumnName("his_id_tarefa").IsRequired();
        builder.Property(e => e.HisIdRdo).HasColumnName("his_id_rdo").IsRequired();
        builder.Property(e => e.HisIdStatus).HasColumnName("his_id_status").IsRequired();
        builder.Property(e => e.HisDtData).HasColumnName("his_dt_data").HasColumnType("datetime");
        builder.Property(e => e.HisDsFoto).HasColumnName("his_ds_foto").HasMaxLength(200).IsUnicode(false);
        builder.Property(e => e.HisDsComentario).HasColumnName("his_ds_comentario").HasMaxLength(500).IsUnicode(false);
        builder.Property(e => e.HisNrHorasTrabalhadas).HasColumnName("his_nr_horas_trabalhadas").IsRequired();
        
        builder.HasIndex(e => e.HisIdTarefa).HasDatabaseName("IX_historico_tarefa_rdo_tarefa");
        builder.HasIndex(e => e.HisIdRdo).HasDatabaseName("IX_historico_tarefa_rdo_rdo");
        builder.HasIndex(e => e.HisIdStatus).HasDatabaseName("IX_historico_tarefa_rdo_status");
        builder.HasIndex(e => e.HisDtData).HasDatabaseName("IX_historico_tarefa_rdo_data");
    }
}
