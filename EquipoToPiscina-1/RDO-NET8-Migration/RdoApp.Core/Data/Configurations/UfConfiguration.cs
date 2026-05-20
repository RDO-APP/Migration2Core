using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class UfConfiguration : IEntityTypeConfiguration<Uf>
    {
        public void Configure(EntityTypeBuilder<Uf> builder)
        {
            builder.ToTable("uf");
            
            builder.HasKey(u => u.Id);
            
            builder.Property(u => u.Id)
                .HasColumnName("ufe_id_uf")
                .ValueGeneratedOnAdd();

            builder.Property(u => u.Descricao)
                .HasColumnName("ufe_ds_uf")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(u => u.Sigla)
                .HasColumnName("ufe_ds_sigla")
                .HasMaxLength(2)
                .IsRequired();
        }
    }
}