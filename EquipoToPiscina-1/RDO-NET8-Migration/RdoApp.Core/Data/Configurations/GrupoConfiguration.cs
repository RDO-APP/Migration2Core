using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class GrupoConfiguration : IEntityTypeConfiguration<Grupo>
    {
        public void Configure(EntityTypeBuilder<Grupo> builder)
        {
            builder.ToTable("grupo");
            
            builder.HasKey(g => g.Id);
            
            builder.Property(g => g.Id)
                .HasColumnName("gru_id_grupo")
                .ValueGeneratedOnAdd();

            builder.Property(g => g.Nome)
                .HasColumnName("gru_nm_nome")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(g => g.MenuId)
                .HasColumnName("gru_id_menu")
                .IsRequired();

            builder.Property(g => g.LicencaId)
                .HasColumnName("gru_id_licenca");

            builder.Property(g => g.StatusDiretor)
                .HasColumnName("gru_st_diretor");

            builder.Property(g => g.StatusContratante)
                .HasColumnName("gru_st_contratante");
        }
    }
}