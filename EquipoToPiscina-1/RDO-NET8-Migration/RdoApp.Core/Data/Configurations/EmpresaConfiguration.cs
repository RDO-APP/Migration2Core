using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class EmpresaConfiguration : IEntityTypeConfiguration<Empresa>
    {
        public void Configure(EntityTypeBuilder<Empresa> builder)
        {
            builder.ToTable("empresa");

            builder.HasKey(e => e.Id);

            builder.Property(e => e.Id)
                .HasColumnName("emp_id_empresa")
                .ValueGeneratedOnAdd();

            builder.Property(e => e.MunicipioId)
                .HasColumnName("emp_id_municipio");

            builder.Property(e => e.RamoId)
                .HasColumnName("emp_id_ramo");

            builder.Property(e => e.SetorId)
                .HasColumnName("emp_id_setor");

            builder.Property(e => e.RazaoSocial)
                .HasColumnName("emp_ds_razao_social")
                .HasMaxLength(255);

            builder.Property(e => e.NomeFantasia)
                .HasColumnName("emp_nm_fantasia")
                .HasMaxLength(255);

            builder.Property(e => e.Cnpj)
                .HasColumnName("emp_nr_cnpj")
                .HasMaxLength(18);

            builder.Property(e => e.Logradouro)
                .HasColumnName("emp_ds_logradouro")
                .HasMaxLength(255);

            builder.Property(e => e.Numero)
                .HasColumnName("emp_ds_numero")
                .HasMaxLength(20);

            builder.Property(e => e.Bairro)
                .HasColumnName("emp_ds_bairro")
                .HasMaxLength(100);

            builder.Property(e => e.Cep)
                .HasColumnName("emp_ds_cep")
                .HasMaxLength(10);

            builder.Property(e => e.Logo)
                .HasColumnName("emp_ds_logo")
                .HasMaxLength(500);

            builder.Property(e => e.Telefone)
                .HasColumnName("emp_ds_telefone")
                .HasMaxLength(20);

            builder.Property(e => e.ColaboradorId)
                .HasColumnName("emp_id_colaborador");

            builder.Property(e => e.Complemento)
                .HasColumnName("emp_ds_complemento")
                .HasMaxLength(100);

            builder.Property(e => e.LicencaId)
                .HasColumnName("emp_id_licenca");

            builder.Property(e => e.Token)
                .HasColumnName("emp_id_token")
                .HasMaxLength(255);

            // Relacionamentos
            builder.HasOne(e => e.Colaborador)
                .WithMany(c => c.Empresas)
                .HasForeignKey(e => e.ColaboradorId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(e => e.Municipio)
                .WithMany(m => m.Empresas)
                .HasForeignKey(e => e.MunicipioId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasOne(e => e.Ramo)
                .WithMany(r => r.Empresas)
                .HasForeignKey(e => e.RamoId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasOne(e => e.Setor)
                .WithMany(s => s.Empresas)
                .HasForeignKey(e => e.SetorId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.HasOne(e => e.Licenca)
                .WithMany(l => l.Empresas)
                .HasForeignKey(e => e.LicencaId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}