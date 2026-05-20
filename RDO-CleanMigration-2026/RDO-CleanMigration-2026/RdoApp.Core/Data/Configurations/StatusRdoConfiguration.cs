using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for StatusRdo (Report Status) entity
/// </summary>
public class StatusRdoConfiguration : IEntityTypeConfiguration<StatusRdo>
{
    public void Configure(EntityTypeBuilder<StatusRdo> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("status_rdo");

        // Primary key
        builder.HasKey(s => s.StrIdStatus);
        builder.Property(s => s.StrIdStatus)
            .HasColumnName("str_id_status")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(s => s.StrDsStatus)
            .HasColumnName("str_ds_status")
            .HasMaxLength(100)
            .IsRequired();

        // Indexes
        builder.HasIndex(s => s.StrDsStatus);
    }
}
