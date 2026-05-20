using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
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
}