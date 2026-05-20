using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class UnidadeDeMedidaConfiguration : IEntityTypeConfiguration<UnidadeDeMedida>
    {
        public void Configure(EntityTypeBuilder<UnidadeDeMedida> builder)
        {
            builder.ToTable("unidade_de_medida");
            
            builder.HasKey(u => u.Id);
            
            builder.Property(u => u.Id)
                .HasColumnName("unm_id_unidade")
                .ValueGeneratedOnAdd();

            builder.Property(u => u.Descricao)
                .HasColumnName("unm_ds_unidade")
                .HasMaxLength(100)
                .IsRequired();

            builder.Property(u => u.Simbolo)
                .HasColumnName("unm_ds_simbolo")
                .HasMaxLength(10)
                .IsRequired();

            // TEMPORARILY DISABLED: Configure the relationship properly to avoid shadow properties
            // This relationship is causing "Unknown column 't.UnidadeDeMedidaId'" error
            // We'll re-enable this after fixing the database mapping issues
            // builder.HasMany(u => u.Tarefas)
            //     .WithOne() // No navigation property on Tarefa side
            //     .HasForeignKey(t => t.UnidadeId)
            //     .OnDelete(DeleteBehavior.SetNull);
        }
    }
}