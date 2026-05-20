using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class StatusTarefaConfiguration : IEntityTypeConfiguration<StatusTarefa>
    {
        public void Configure(EntityTypeBuilder<StatusTarefa> builder)
        {
            builder.ToTable("status_tarefa");
            
            builder.HasKey(s => s.Id);
            
            builder.Property(s => s.Id)
                .HasColumnName("stt_id_status")
                .ValueGeneratedOnAdd();

            builder.Property(s => s.Descricao)
                .HasColumnName("stt_ds_status")
                .HasMaxLength(100)
                .IsRequired();

            // Relacionamento com Tarefa já configurado no TarefaConfiguration
        }
    }
}