using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class RamoConfiguration : IEntityTypeConfiguration<Ramo>
    {
        public void Configure(EntityTypeBuilder<Ramo> builder)
        {
            builder.ToTable("ramo");

            builder.HasKey(r => r.Id);

            builder.Property(r => r.Id)
                .HasColumnName("ram_id_ramo")
                .ValueGeneratedOnAdd();

            builder.Property(r => r.Descricao)
                .HasColumnName("ram_ds_ramo")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(r => r.IdRamoLoja)
                .HasColumnName("ram_id_ramo_loja")
                .HasMaxLength(255);
        }
    }
}