using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Improdutividade entity
/// Maps to legacy 'improdutividade' table
/// </summary>
public class ImprodutividadeConfiguration : IEntityTypeConfiguration<Improdutividade>
{
    public void Configure(EntityTypeBuilder<Improdutividade> builder)
    {
        // Table mapping
        builder.ToTable("improdutividade");

        // Primary key
        builder.HasKey(e => e.ImpIdImprodutividade);
        builder.Property(e => e.ImpIdImprodutividade)
            .HasColumnName("imp_id_improdutividade")
            .ValueGeneratedOnAdd();

        // Boolean properties (flags for different unproductive time reasons)
        builder.Property(e => e.ImpStClima)
            .HasColumnName("imp_st_clima")
            .IsRequired();

        builder.Property(e => e.ImpStMaterial)
            .HasColumnName("imp_st_material")
            .IsRequired();

        builder.Property(e => e.ImpStParalizacao)
            .HasColumnName("imp_st_paralizacao")
            .IsRequired();

        builder.Property(e => e.ImpStEquipamento)
            .HasColumnName("imp_st_equipamento")
            .IsRequired();

        builder.Property(e => e.ImpStContratante)
            .HasColumnName("imp_st_contratante")
            .IsRequired();

        builder.Property(e => e.ImpStFornecedores)
            .HasColumnName("imp_st_fornecedores")
            .IsRequired();

        builder.Property(e => e.ImpStMaodeobra)
            .HasColumnName("imp_st_maodeobra")
            .IsRequired();

        builder.Property(e => e.ImpStProjeto)
            .HasColumnName("imp_st_projeto")
            .IsRequired();

        builder.Property(e => e.ImpStPlanejamento)
            .HasColumnName("imp_st_planejamento")
            .IsRequired();

        builder.Property(e => e.ImpStAcidentes)
            .HasColumnName("imp_st_acidentes")
            .IsRequired();

        // Relationships will be configured when related entities are fully implemented
        // No foreign keys in this entity - it's referenced by Rdo
    }
}
