using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
    {
        public void Configure(EntityTypeBuilder<Usuario> builder)
        {
            builder.ToTable("usuario");
            
            builder.HasKey(u => u.Id);
            
            builder.Property(u => u.Id)
                .HasColumnName("usu_id_usuario")
                .ValueGeneratedOnAdd();

            builder.Property(u => u.Email)
                .HasColumnName("usu_ds_email")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(u => u.Senha)
                .HasColumnName("usu_ds_senha")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(u => u.GrupoId)
                .HasColumnName("usu_id_grupo")
                .IsRequired();

            builder.Property(u => u.Status)
                .HasColumnName("usu_st_status");

            builder.Property(u => u.AlterarSenha)
                .HasColumnName("usu_st_alterar_senha");

            // Relationships
            builder.HasOne(u => u.Grupo)
                .WithMany()
                .HasForeignKey(u => u.GrupoId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}