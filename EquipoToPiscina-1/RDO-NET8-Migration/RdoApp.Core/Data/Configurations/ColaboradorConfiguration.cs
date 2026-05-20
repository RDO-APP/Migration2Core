using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class ColaboradorConfiguration : IEntityTypeConfiguration<Colaborador>
    {
        public void Configure(EntityTypeBuilder<Colaborador> builder)
        {
            // Tabela
            builder.ToTable("colaborador");

            // Chave primária
            builder.HasKey(c => c.Id);

            // Propriedades - TODOS OS CAMPOS DO GILBERTO
            builder.Property(c => c.Id)
                .HasColumnName("col_id_colaborador")
                .ValueGeneratedOnAdd();

            builder.Property(c => c.MunicipioId)
                .HasColumnName("col_id_municipio");

            builder.Property(c => c.Cpf)
                .HasColumnName("col_nr_cpf")
                .HasMaxLength(14);

            builder.Property(c => c.Nome)
                .HasColumnName("col_nm_colaborador")
                .HasMaxLength(255);

            builder.Property(c => c.Email)
                .HasColumnName("col_ds_email")
                .HasMaxLength(255);

            builder.Property(c => c.Telefone)
                .HasColumnName("col_ds_telefone_principal")
                .HasMaxLength(20);

            builder.Property(c => c.TelefoneSecundario)
                .HasColumnName("col_ds_telefone_secundario")
                .HasMaxLength(20);

            builder.Property(c => c.Foto)
                .HasColumnName("col_ds_foto")
                .HasMaxLength(500);

            builder.Property(c => c.Assinatura)
                .HasColumnName("col_ds_assinatura")
                .HasMaxLength(500);

            builder.Property(c => c.Senha)
                .HasColumnName("col_ds_senha")
                .HasMaxLength(255);

            builder.Property(c => c.Logradouro)
                .HasColumnName("col_ds_logradouro")
                .HasMaxLength(255);

            builder.Property(c => c.Bairro)
                .HasColumnName("col_ds_bairro")
                .HasMaxLength(100);

            builder.Property(c => c.Numero)
                .HasColumnName("col_ds_numero")
                .HasMaxLength(20);

            builder.Property(c => c.DataNascimento)
                .HasColumnName("col_dt_nascimento");

            builder.Property(c => c.Crea)
                .HasColumnName("col_ds_crea")
                .HasMaxLength(50);

            builder.Property(c => c.Login)
                .HasColumnName("col_ds_login")
                .HasMaxLength(100);

            builder.Property(c => c.Sexo)
                .HasColumnName("col_ds_sexo")
                .HasMaxLength(1);

            builder.Property(c => c.Cep)
                .HasColumnName("col_ds_cep")
                .HasMaxLength(10);

            builder.Property(c => c.Complemento)
                .HasColumnName("col_ds_complemento")
                .HasMaxLength(100);

            builder.Property(c => c.Ativo)
                .HasColumnName("col_st_admin")
                .HasDefaultValue(true);

            // Relacionamentos - simplificados para evitar shadow properties
            // Remover relacionamentos complexos que causam conflitos

            // Índices
            builder.HasIndex(c => c.Cpf)
                .IsUnique()
                .HasDatabaseName("IX_colaborador_cpf");

            builder.HasIndex(c => c.Login)
                .IsUnique()
                .HasDatabaseName("IX_colaborador_login");
        }
    }
}