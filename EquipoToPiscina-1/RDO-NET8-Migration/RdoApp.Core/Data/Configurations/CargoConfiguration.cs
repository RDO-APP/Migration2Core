using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class CargoConfiguration : IEntityTypeConfiguration<Cargo>
    {
        public void Configure(EntityTypeBuilder<Cargo> builder)
        {
            builder.ToTable("cargo");
            
            builder.HasKey(c => c.Id);
            
            builder.Property(c => c.Id)
                .HasColumnName("car_id_cargo")
                .ValueGeneratedOnAdd();

            builder.Property(c => c.Descricao)
                .HasColumnName("car_ds_cargo")
                .HasMaxLength(255)
                .IsRequired();
        }
    }
}