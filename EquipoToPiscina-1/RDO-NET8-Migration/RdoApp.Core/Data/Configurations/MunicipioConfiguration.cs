using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class MunicipioConfiguration : IEntityTypeConfiguration<Municipio>
    {
        public void Configure(EntityTypeBuilder<Municipio> builder)
        {
            builder.ToTable("municipio");
            
            builder.HasKey(m => m.Id);
            
            builder.Property(m => m.Id)
                .HasColumnName("mun_id_municipio")
                .ValueGeneratedOnAdd();

            builder.Property(m => m.UfId)
                .HasColumnName("mun_id_uf")
                .IsRequired();

            builder.Property(m => m.Descricao)
                .HasColumnName("mun_ds_municipio")
                .HasMaxLength(255)
                .IsRequired();

            // Relationships
            builder.HasOne(m => m.Uf)
                .WithMany(u => u.Municipios)
                .HasForeignKey(m => m.UfId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}