using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for StatusTarefa (Task Status) entity
/// </summary>
public class StatusTarefaConfiguration : IEntityTypeConfiguration<StatusTarefa>
{
    public void Configure(EntityTypeBuilder<StatusTarefa> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("status_tarefa");

        // Primary key
        builder.HasKey(st => st.SttIdStatus);
        builder.Property(st => st.SttIdStatus)
            .HasColumnName("stt_id_status")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(st => st.SttDsStatus)
            .HasColumnName("stt_ds_status")
            .HasMaxLength(50)
            .IsRequired();

        // Indexes
        builder.HasIndex(st => st.SttDsStatus);
    }
}
