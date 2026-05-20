using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class SetorConfiguration : IEntityTypeConfiguration<Setor>
    {
        public void Configure(EntityTypeBuilder<Setor> builder)
        {
            builder.ToTable("setor");

            builder.HasKey(s => s.Id);

            builder.Property(s => s.Id)
                .HasColumnName("set_id_setor")
                .ValueGeneratedOnAdd();

            builder.Property(s => s.Descricao)
                .HasColumnName("set_ds_setor")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(s => s.IdSetorLoja)
                .HasColumnName("set_id_setor_loja")
                .HasMaxLength(255);
        }
    }
}