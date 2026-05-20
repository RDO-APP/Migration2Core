using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
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
}