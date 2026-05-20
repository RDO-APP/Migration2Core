using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class ObraConfiguration : IEntityTypeConfiguration<Obra>
    {
        public void Configure(EntityTypeBuilder<Obra> builder)
        {
            builder.ToTable("obra");
            
            builder.HasKey(o => o.Id);
            
            builder.Property(o => o.Id)
                .HasColumnName("obr_id_obra")
                .ValueGeneratedOnAdd();

            builder.Property(o => o.Descricao)
                .HasColumnName("obr_ds_obra")
                .HasMaxLength(200)
                .IsRequired();

            // Campos de endereço corretos (baseado na análise do Gilberto)
            builder.Property(o => o.Logradouro)
                .HasColumnName("obr_ds_logradouro")
                .HasMaxLength(255);

            builder.Property(o => o.Numero)
                .HasColumnName("obr_ds_numero")
                .HasMaxLength(20);

            builder.Property(o => o.Bairro)
                .HasColumnName("obr_ds_bairro")
                .HasMaxLength(100);

            builder.Property(o => o.Cep)
                .HasColumnName("obr_ds_cep")
                .HasMaxLength(10);

            builder.Property(o => o.Complemento)
                .HasColumnName("obr_ds_complemento")
                .HasMaxLength(100);

            builder.Property(o => o.DataInicio)
                .HasColumnName("obr_dt_inicio")
                .IsRequired();

            builder.Property(o => o.DataPrevisaoFim)
                .HasColumnName("obr_dt_previsao_fim");

            builder.Property(o => o.DataFim)
                .HasColumnName("obr_dt_fim");

            builder.Property(o => o.MunicipioId)
                .HasColumnName("obr_id_municipio")
                .IsRequired();

            builder.Property(o => o.ColaboradorId)
                .HasColumnName("obr_id_colaborador");

            // Business Relationship Fields (3 fields)
            builder.Property(o => o.EmpresaContratanteId)
                .HasColumnName("obr_id_empresa_contratante");

            builder.Property(o => o.EmpresaContratadaId)
                .HasColumnName("obr_id_empresa_contratada");

            builder.Property(o => o.DonoId)
                .HasColumnName("obr_id_dono");

            // Area & Measurement Fields (2 fields)
            builder.Property(o => o.AreaTotal)
                .HasColumnName("obr_nr_area_total");

            builder.Property(o => o.AreaTotalConstruida)
                .HasColumnName("obr_nr_area_total_construida");

            // Media & Documentation Fields (1 field)
            builder.Property(o => o.Foto)
                .HasColumnName("obr_ds_foto")
                .HasMaxLength(255);

            // Schedule & Timeline Fields (4 fields)
            builder.Property(o => o.DataVencimento)
                .HasColumnName("obr_dt_vencimento");

            builder.Property(o => o.HorasSemana)
                .HasColumnName("obr_nr_horas_semana");

            builder.Property(o => o.HorasSabado)
                .HasColumnName("obr_nr_horas_sabado");

            builder.Property(o => o.HorasDomingo)
                .HasColumnName("obr_nr_horas_domingo");

            // Legal & Administrative Fields (2 fields)
            builder.Property(o => o.Art)
                .HasColumnName("obr_ds_art")
                .HasMaxLength(100);

            builder.Property(o => o.CodigoConvite)
                .HasColumnName("obr_cd_convite")
                .HasMaxLength(50);

            // Relacionamento com Municipio
            builder.HasOne(o => o.Municipio)
                .WithMany(m => m.Obras)
                .HasForeignKey(o => o.MunicipioId)
                .OnDelete(DeleteBehavior.Restrict);

            // Relacionamento com Etapa já configurado no EtapaConfiguration
        }
    }
}