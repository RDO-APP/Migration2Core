using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Cargo (Job Position) entity
/// </summary>
public class CargoConfiguration : IEntityTypeConfiguration<Cargo>
{
    public void Configure(EntityTypeBuilder<Cargo> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("cargo");

        // Primary key
        builder.HasKey(c => c.CarIdCargo);
        builder.Property(c => c.CarIdCargo)
            .HasColumnName("car_id_cargo")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(c => c.CarDsCargo)
            .HasColumnName("car_ds_cargo")
            .HasMaxLength(100)
            .IsRequired();

        // Indexes
        builder.HasIndex(c => c.CarDsCargo);
    }
}
