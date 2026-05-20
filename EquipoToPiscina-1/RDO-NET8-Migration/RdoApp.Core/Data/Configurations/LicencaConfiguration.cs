using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class LicencaConfiguration : IEntityTypeConfiguration<Licenca>
    {
        public void Configure(EntityTypeBuilder<Licenca> builder)
        {
            builder.ToTable("licenca");

            builder.HasKey(l => l.Id);

            builder.Property(l => l.Id)
                .HasColumnName("lic_id_licenca")
                .ValueGeneratedOnAdd();

            builder.Property(l => l.Descricao)
                .HasColumnName("lic_ds_licenca")
                .HasMaxLength(255);

            builder.Property(l => l.QuantidadeUsuarios)
                .HasColumnName("lic_nr_qtd_usuarios");

            builder.Property(l => l.QuantidadeObras)
                .HasColumnName("lic_nr_qtd_obras");

            builder.Property(l => l.QuantidadeImagensTarefas)
                .HasColumnName("lic_qtd_imagens_tarefas");

            builder.Property(l => l.QuantidadeTarefasObra)
                .HasColumnName("lic_qtd_tarefas_obra");

            builder.Property(l => l.PermiteLogoRdo)
                .HasColumnName("lic_st_permite_logo_rdo");

            builder.Property(l => l.LicencaLojaId)
                .HasColumnName("lic_id_licenca_loja")
                .HasMaxLength(50);
        }
    }
}