using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Colaborador (Worker/Employee) entity
/// </summary>
public class ColaboradorConfiguration : IEntityTypeConfiguration<Colaborador>
{
    public void Configure(EntityTypeBuilder<Colaborador> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("colaborador");

        // Primary key
        builder.HasKey(c => c.ColIdColaborador);
        builder.Property(c => c.ColIdColaborador)
            .HasColumnName("col_id_colaborador")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(c => c.ColIdMunicipio)
            .HasColumnName("col_id_municipio");

        // Properties
        builder.Property(c => c.ColNrCpf)
            .HasColumnName("col_nr_cpf")
            .HasMaxLength(14)
            .IsRequired();

        builder.Property(c => c.ColNmColaborador)
            .HasColumnName("col_nm_colaborador")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(c => c.ColDsEmail)
            .HasColumnName("col_ds_email")
            .HasMaxLength(255);

        builder.Property(c => c.ColDsTelefonePrincipal)
            .HasColumnName("col_ds_telefone_principal")
            .HasMaxLength(20);

        builder.Property(c => c.ColDsTelefoneSecundario)
            .HasColumnName("col_ds_telefone_secundario")
            .HasMaxLength(20);

        builder.Property(c => c.ColDsFoto)
            .HasColumnName("col_ds_foto")
            .HasMaxLength(255);

        builder.Property(c => c.ColDsAssinatura)
            .HasColumnName("col_ds_assinatura")
            .HasMaxLength(255);

        builder.Property(c => c.ColDsSenha)
            .HasColumnName("col_ds_senha")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(c => c.ColDsLogradouro)
            .HasColumnName("col_ds_logradouro")
            .HasMaxLength(255);

        builder.Property(c => c.ColDsBairro)
            .HasColumnName("col_ds_bairro")
            .HasMaxLength(100);

        builder.Property(c => c.ColDsNumero)
            .HasColumnName("col_ds_numero")
            .HasMaxLength(20);

        builder.Property(c => c.ColDtNascimento)
            .HasColumnName("col_dt_nascimento")
            .HasColumnType("datetime");

        builder.Property(c => c.ColDsCrea)
            .HasColumnName("col_ds_crea")
            .HasMaxLength(50);

        builder.Property(c => c.ColDsLogin)
            .HasColumnName("col_ds_login")
            .HasMaxLength(100);

        builder.Property(c => c.ColDsSexo)
            .HasColumnName("col_ds_sexo")
            .HasMaxLength(1);

        builder.Property(c => c.ColDsCep)
            .HasColumnName("col_ds_cep")
            .HasMaxLength(10);

        builder.Property(c => c.ColDsComplemento)
            .HasColumnName("col_ds_complemento")
            .HasMaxLength(255);

        builder.Property(c => c.ColStAdmin)
            .HasColumnName("col_st_admin");

        // Indexes
        builder.HasIndex(c => c.ColNrCpf);
        builder.HasIndex(c => c.ColDsEmail);
        builder.HasIndex(c => c.ColDsLogin);
        builder.HasIndex(c => c.ColNmColaborador);
        builder.HasIndex(c => c.ColIdMunicipio);
    }
}
