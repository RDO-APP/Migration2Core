using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for ObraColaborador entity
/// Maps to legacy 'obra_colaborador' table
/// </summary>
public class ObraColaboradorConfiguration : IEntityTypeConfiguration<ObraColaborador>
{
    public void Configure(EntityTypeBuilder<ObraColaborador> builder)
    {
        // Table mapping
        builder.ToTable("obra_colaborador");

        // Primary key
        builder.HasKey(e => e.OcoIdObraColaborador);
        builder.Property(e => e.OcoIdObraColaborador)
            .HasColumnName("oco_id_obra_colaborador")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.OcoIdObra)
            .HasColumnName("oco_id_obra")
            .IsRequired();

        builder.Property(e => e.OcoIdColaborador)
            .HasColumnName("oco_id_colaborador")
            .IsRequired();

        builder.Property(e => e.OcoIdCargo)
            .HasColumnName("oco_id_cargo")
            .IsRequired();

        builder.Property(e => e.OcoIdGrupo)
            .HasColumnName("oco_id_grupo")
            .IsRequired();

        // Properties
        builder.Property(e => e.OcoDtContratacao)
            .HasColumnName("oco_dt_contratacao")
            .HasColumnType("datetime");

        builder.Property(e => e.OcoStContratanteContratada)
            .HasColumnName("oco_st_contratante_contratada")
            .HasMaxLength(1)
            .IsUnicode(false);

        // Indexes for foreign keys
        builder.HasIndex(e => e.OcoIdObra)
            .HasDatabaseName("IX_obra_colaborador_obra");

        builder.HasIndex(e => e.OcoIdColaborador)
            .HasDatabaseName("IX_obra_colaborador_colaborador");

        builder.HasIndex(e => e.OcoIdCargo)
            .HasDatabaseName("IX_obra_colaborador_cargo");

        builder.HasIndex(e => e.OcoIdGrupo)
            .HasDatabaseName("IX_obra_colaborador_grupo");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Cargo)
        //     .WithMany(p => p.ObraColaboradores)
        //     .HasForeignKey(d => d.OcoIdCargo)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Colaborador)
        //     .WithMany(p => p.ObraColaboradores)
        //     .HasForeignKey(d => d.OcoIdColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Grupo)
        //     .WithMany(p => p.ObraColaboradores)
        //     .HasForeignKey(d => d.OcoIdGrupo)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Obra)
        //     .WithMany(p => p.ObraColaboradores)
        //     .HasForeignKey(d => d.OcoIdObra)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
