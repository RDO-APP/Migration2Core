using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Obra (Project/Work) entity
/// CRITICAL: This entity has 3 foreign keys to Empresa (owner, contractor, contracted)
/// </summary>
public class ObraConfiguration : IEntityTypeConfiguration<Obra>
{
    public void Configure(EntityTypeBuilder<Obra> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("obra");

        // Primary key
        builder.HasKey(o => o.ObrIdObra);
        builder.Property(o => o.ObrIdObra)
            .HasColumnName("obr_id_obra")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(o => o.ObrIdMunicipio)
            .HasColumnName("obr_id_municipio")
            .IsRequired();

        builder.Property(o => o.ObrIdEmpresaContratante)
            .HasColumnName("obr_id_empresa_contratante");

        builder.Property(o => o.ObrIdEmpresaContratada)
            .HasColumnName("obr_id_empresa_contratada");

        builder.Property(o => o.ObrIdDono)
            .HasColumnName("obr_id_dono");

        builder.Property(o => o.ObrIdColaborador)
            .HasColumnName("obr_id_colaborador");

        // Properties
        builder.Property(o => o.ObrDsObra)
            .HasColumnName("obr_ds_obra")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(o => o.ObrNrAreaTotal)
            .HasColumnName("obr_nr_area_total");

        builder.Property(o => o.ObrNrAreaTotalConstruida)
            .HasColumnName("obr_nr_area_total_construida");

        builder.Property(o => o.ObrDsLogradouro)
            .HasColumnName("obr_ds_logradouro")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(o => o.ObrDsNumero)
            .HasColumnName("obr_ds_numero")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(o => o.ObrDsBairro)
            .HasColumnName("obr_ds_bairro")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(o => o.ObrDsCep)
            .HasColumnName("obr_ds_cep")
            .HasMaxLength(10)
            .IsRequired();

        builder.Property(o => o.ObrDsFoto)
            .HasColumnName("obr_ds_foto")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(o => o.ObrDtInicio)
            .HasColumnName("obr_dt_inicio")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(o => o.ObrDtPrevisaoFim)
            .HasColumnName("obr_dt_previsao_fim")
            .HasColumnType("datetime");

        builder.Property(o => o.ObrDtFim)
            .HasColumnName("obr_dt_fim")
            .HasColumnType("datetime");

        builder.Property(o => o.ObrDtVencimento)
            .HasColumnName("obr_dt_vencimento")
            .HasColumnType("datetime");

        builder.Property(o => o.ObrNrHorasSemana)
            .HasColumnName("obr_nr_horas_semana");

        builder.Property(o => o.ObrNrHorasSabado)
            .HasColumnName("obr_nr_horas_sabado");

        builder.Property(o => o.ObrNrHorasDomingo)
            .HasColumnName("obr_nr_horas_domingo");

        builder.Property(o => o.ObrDsComplemento)
            .HasColumnName("obr_ds_complemento")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(o => o.ObrDsArt)
            .HasColumnName("obr_ds_art")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(o => o.ObrCdConvite)
            .HasColumnName("obr_cd_convite")
            .HasMaxLength(50)
            .IsRequired();

        // Indexes
        builder.HasIndex(o => o.ObrIdMunicipio);
        builder.HasIndex(o => o.ObrIdEmpresaContratante);
        builder.HasIndex(o => o.ObrIdEmpresaContratada);
        builder.HasIndex(o => o.ObrIdDono);
        builder.HasIndex(o => o.ObrIdColaborador);
        builder.HasIndex(o => o.ObrDsObra);
        builder.HasIndex(o => o.ObrCdConvite);
        builder.HasIndex(o => o.ObrDtInicio);

        // TODO: Configure multiple foreign key relationships to Empresa when navigation properties are uncommented
        // builder.HasOne(o => o.EmpresaDono)
        //     .WithMany(e => e.ObrasComoDono)
        //     .HasForeignKey(o => o.ObrIdDono);
        //
        // builder.HasOne(o => o.EmpresaContratante)
        //     .WithMany(e => e.ObrasComoContratante)
        //     .HasForeignKey(o => o.ObrIdEmpresaContratante);
        //
        // builder.HasOne(o => o.EmpresaContratada)
        //     .WithMany(e => e.ObrasComoContratada)
        //     .HasForeignKey(o => o.ObrIdEmpresaContratada);
    }
}
