using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class EtapaConfiguration : IEntityTypeConfiguration<Etapa>
    {
        public void Configure(EntityTypeBuilder<Etapa> builder)
        {
            builder.ToTable("etapa");
            
            builder.HasKey(e => e.Id);
            
            builder.Property(e => e.Id)
                .HasColumnName("eta_id_etapa")
                .ValueGeneratedOnAdd();

            builder.Property(e => e.ObraId)
                .HasColumnName("eta_id_obra")
                .IsRequired();

            builder.Property(e => e.Descricao)
                .HasColumnName("eta_ds_etapa")
                .HasMaxLength(200)
                .IsRequired(false); // CRITICAL FIX: Allow null values to match entity definition

            // Relacionamento com Obra
            builder.HasOne(e => e.Obra)
                .WithMany(o => o.Etapas)
                .HasForeignKey(e => e.ObraId)
                .OnDelete(DeleteBehavior.Restrict);

            // Relacionamento com Tarefa já configurado no TarefaConfiguration
        }
    }
}