using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class ObraTarefaEquipamentoConfiguration : IEntityTypeConfiguration<ObraTarefaEquipamento>
    {
        public void Configure(EntityTypeBuilder<ObraTarefaEquipamento> builder)
        {
            builder.ToTable("obra_tarefa_equipamento");
            
            builder.HasKey(ote => ote.Id);
            
            builder.Property(ote => ote.Id)
                .HasColumnName("ote_id_obra_tarefa_euipamento") // Note: keeping original typo for compatibility
                .ValueGeneratedOnAdd();

            builder.Property(ote => ote.ObraEquipamentoId)
                .HasColumnName("ote_id_obra_equipamento")
                .IsRequired();

            builder.Property(ote => ote.TarefaId)
                .HasColumnName("ote_id_tarefa")
                .IsRequired();

            // Relationships
            builder.HasOne(ote => ote.ObraEquipamento)
                .WithMany()
                .HasForeignKey(ote => ote.ObraEquipamentoId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(ote => ote.Tarefa)
                .WithMany()
                .HasForeignKey(ote => ote.TarefaId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}