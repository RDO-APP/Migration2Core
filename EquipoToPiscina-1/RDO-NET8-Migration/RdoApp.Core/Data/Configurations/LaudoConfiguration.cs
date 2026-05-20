using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class LaudoConfiguration : IEntityTypeConfiguration<Laudo>
    {
        public void Configure(EntityTypeBuilder<Laudo> builder)
        {
            builder.ToTable("laudo");
            
            builder.HasKey(l => l.Id);
            
            builder.Property(l => l.Id)
                .HasColumnName("lau_id_laudo")
                .ValueGeneratedOnAdd();

            builder.Property(l => l.StatusId)
                .HasColumnName("lau_id_status")
                .IsRequired();

            builder.Property(l => l.ObraId)
                .HasColumnName("lau_id_obra")
                .IsRequired();

            builder.Property(l => l.DataLaudo)
                .HasColumnName("lau_dt_laudo")
                .IsRequired();

            builder.Property(l => l.ComentarioAssinatura)
                .HasColumnName("lau_ds_comentario_assinatura")
                .HasMaxLength(500);

            builder.Property(l => l.ColaboradorId)
                .HasColumnName("lau_id_colaborador");

            builder.Property(l => l.DataGeracao)
                .HasColumnName("lau_dt_geracao");

            builder.Property(l => l.TipoComentarioAssinatura)
                .HasColumnName("lau_tp_comentario_assinatura")
                .HasMaxLength(1);

            builder.Property(l => l.ComentarioGeracao)
                .HasColumnName("lau_ds_comentario_geracao")
                .HasMaxLength(500);

            builder.Property(l => l.TipoComentarioGeracao)
                .HasColumnName("lau_tp_comentario_geracao")
                .HasMaxLength(1);

            // Water Quality Fields - Pool Management (9 fields)
            builder.Property(l => l.NivelCloro)
                .HasColumnName("lau_tp_nivel_cloro");

            builder.Property(l => l.Ph)
                .HasColumnName("lau_tp_ph");

            builder.Property(l => l.Alcalinidade)
                .HasColumnName("lau_tp_alcalinidade");

            builder.Property(l => l.Limpidez)
                .HasColumnName("lau_tp_limpidez");

            builder.Property(l => l.Superficie)
                .HasColumnName("lau_tp_superficie");

            builder.Property(l => l.Fundo)
                .HasColumnName("lau_tp_fundo");

            builder.Property(l => l.NivelCloro2)
                .HasColumnName("lau_tp_nivel_cloro_2");

            builder.Property(l => l.NivelBacterias)
                .HasColumnName("lau_tp_nivel_bacterias");

            builder.Property(l => l.NivelProliferacao)
                .HasColumnName("lau_tp_nivel_proliferacao");

            // Relationships
            builder.HasOne(l => l.Status)
                .WithMany(s => s.Laudos)
                .HasForeignKey(l => l.StatusId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(l => l.Obra)
                .WithMany()
                .HasForeignKey(l => l.ObraId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(l => l.Colaborador)
                .WithMany()
                .HasForeignKey(l => l.ColaboradorId)
                .OnDelete(DeleteBehavior.SetNull);
        }
    }
}