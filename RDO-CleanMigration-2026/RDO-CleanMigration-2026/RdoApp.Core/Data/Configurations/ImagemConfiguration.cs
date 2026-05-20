using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class ImagemConfiguration : IEntityTypeConfiguration<Imagem>
{
    public void Configure(EntityTypeBuilder<Imagem> builder)
    {
        builder.ToTable("imagem");

        builder.HasKey(e => e.ImaIdImagem);

        builder.Property(e => e.ImaDsCaminho)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(e => e.ImaIdHistoricoTarefaRdo);

        builder.Property(e => e.ImaIdTarefa)
            .IsRequired();

        builder.Property(e => e.ImaDtImagem)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.ImaIdTarefa)
            .HasDatabaseName("idx_imagem_tarefa");

        builder.HasIndex(e => e.ImaIdHistoricoTarefaRdo)
            .HasDatabaseName("idx_imagem_historico");

        builder.HasIndex(e => e.ImaDtImagem)
            .HasDatabaseName("idx_imagem_data");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Tarefa)
        //     .WithMany()
        //     .HasForeignKey(e => e.ImaIdTarefa)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
