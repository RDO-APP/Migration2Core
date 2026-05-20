using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Licenca (License) entity
/// </summary>
public class LicencaConfiguration : IEntityTypeConfiguration<Licenca>
{
    public void Configure(EntityTypeBuilder<Licenca> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("licenca");

        // Primary key
        builder.HasKey(l => l.LicIdLicenca);
        builder.Property(l => l.LicIdLicenca)
            .HasColumnName("lic_id_licenca")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(l => l.LicDsLicenca)
            .HasColumnName("lic_ds_licenca")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(l => l.LicNrQtdUsuarios)
            .HasColumnName("lic_nr_qtd_usuarios");

        builder.Property(l => l.LicNrQtdObras)
            .HasColumnName("lic_nr_qtd_obras");

        builder.Property(l => l.LicQtdImagensTarefas)
            .HasColumnName("lic_qtd_imagens_tarefas")
            .IsRequired();

        builder.Property(l => l.LicQtdTarefasObra)
            .HasColumnName("lic_qtd_tarefas_obra")
            .IsRequired();

        builder.Property(l => l.LicStPermiteLogoRdo)
            .HasColumnName("lic_st_permite_logo_rdo")
            .IsRequired();

        builder.Property(l => l.LicIdLicencaLoja)
            .HasColumnName("lic_id_licenca_loja")
            .HasMaxLength(100)
            .IsRequired();

        // Indexes
        builder.HasIndex(l => l.LicDsLicenca);
        builder.HasIndex(l => l.LicIdLicencaLoja);
    }
}
