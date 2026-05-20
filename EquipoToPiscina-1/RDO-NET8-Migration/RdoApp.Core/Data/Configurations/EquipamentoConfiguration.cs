using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class EquipamentoConfiguration : IEntityTypeConfiguration<Equipamento>
    {
        public void Configure(EntityTypeBuilder<Equipamento> builder)
        {
            builder.ToTable("equipamento");
            
            builder.HasKey(e => e.Id);
            
            builder.Property(e => e.Id)
                .HasColumnName("equ_id_equipamento")
                .ValueGeneratedOnAdd();

            builder.Property(e => e.Descricao)
                .HasColumnName("equ_ds_equipamento")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(e => e.Marca)
                .HasColumnName("equ_ds_marca")
                .HasMaxLength(100);

            builder.Property(e => e.Modelo)
                .HasColumnName("equ_ds_modelo")
                .HasMaxLength(100);

            builder.Property(e => e.TipoEquipamentoId)
                .HasColumnName("equ_id_tipo_equipamento")
                .IsRequired();

            builder.Property(e => e.Imagem)
                .HasColumnName("equ_ds_imagem")
                .HasMaxLength(255);

            // Relationships
            builder.HasOne(e => e.TipoEquipamento)
                .WithMany(te => te.Equipamentos)
                .HasForeignKey(e => e.TipoEquipamentoId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}