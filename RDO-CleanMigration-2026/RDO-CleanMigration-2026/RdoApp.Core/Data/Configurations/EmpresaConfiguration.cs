using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Empresa (Company) entity
/// </summary>
public class EmpresaConfiguration : IEntityTypeConfiguration<Empresa>
{
    public void Configure(EntityTypeBuilder<Empresa> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("empresa");

        // Primary key
        builder.HasKey(e => e.EmpIdEmpresa);
        builder.Property(e => e.EmpIdEmpresa)
            .HasColumnName("emp_id_empresa")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.EmpIdMunicipio)
            .HasColumnName("emp_id_municipio");

        builder.Property(e => e.EmpIdRamo)
            .HasColumnName("emp_id_ramo");

        builder.Property(e => e.EmpIdSetor)
            .HasColumnName("emp_id_setor");

        builder.Property(e => e.EmpIdColaborador)
            .HasColumnName("emp_id_colaborador")
            .IsRequired();

        builder.Property(e => e.EmpIdLicenca)
            .HasColumnName("emp_id_licenca");

        // Properties
        builder.Property(e => e.EmpDsRazaoSocial)
            .HasColumnName("emp_ds_razao_social")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EmpNmFantasia)
            .HasColumnName("emp_nm_fantasia")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EmpNrCnpj)
            .HasColumnName("emp_nr_cnpj")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(e => e.EmpDsLogradouro)
            .HasColumnName("emp_ds_logradouro")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EmpDsNumero)
            .HasColumnName("emp_ds_numero")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(e => e.EmpDsBairro)
            .HasColumnName("emp_ds_bairro")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.EmpDsCep)
            .HasColumnName("emp_ds_cep")
            .HasMaxLength(10)
            .IsRequired();

        builder.Property(e => e.EmpDsLogo)
            .HasColumnName("emp_ds_logo")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EmpDsTelefone)
            .HasColumnName("emp_ds_telefone")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(e => e.EmpDsComplemento)
            .HasColumnName("emp_ds_complemento")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EmpIdToken)
            .HasColumnName("emp_id_token")
            .HasMaxLength(255)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.EmpNrCnpj);
        builder.HasIndex(e => e.EmpNmFantasia);
        builder.HasIndex(e => e.EmpIdMunicipio);
        builder.HasIndex(e => e.EmpIdRamo);
        builder.HasIndex(e => e.EmpIdSetor);
        builder.HasIndex(e => e.EmpIdColaborador);
        builder.HasIndex(e => e.EmpIdLicenca);
    }
}
