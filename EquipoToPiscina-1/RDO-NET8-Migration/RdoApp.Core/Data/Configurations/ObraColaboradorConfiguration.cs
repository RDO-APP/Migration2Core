using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class ObraColaboradorConfiguration : IEntityTypeConfiguration<ObraColaborador>
    {
        public void Configure(EntityTypeBuilder<ObraColaborador> builder)
        {
            builder.ToTable("obra_colaborador");
            
            builder.HasKey(oc => oc.Id);
            
            builder.Property(oc => oc.Id)
                .HasColumnName("oco_id_obra_colaborador")
                .ValueGeneratedOnAdd();

            builder.Property(oc => oc.ObraId)
                .HasColumnName("oco_id_obra")
                .IsRequired();

            builder.Property(oc => oc.ColaboradorId)
                .HasColumnName("oco_id_colaborador")
                .IsRequired();

            builder.Property(oc => oc.CargoId)
                .HasColumnName("oco_id_cargo")
                .IsRequired();

            builder.Property(oc => oc.GrupoId)
                .HasColumnName("oco_id_grupo")
                .IsRequired();

            builder.Property(oc => oc.DataContratacao)
                .HasColumnName("oco_dt_contratacao");

            builder.Property(oc => oc.StatusContratanteContratada)
                .HasColumnName("oco_st_contratante_contratada")
                .HasMaxLength(50);

            // Relationships - Fixed to prevent shadow property generation
            builder.HasOne(oc => oc.Obra)
                .WithMany(o => o.ObraColaboradores)
                .HasForeignKey(oc => oc.ObraId)
                .HasConstraintName("FK_obra_colaborador_obra")
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(oc => oc.Colaborador)
                .WithMany()
                .HasForeignKey(oc => oc.ColaboradorId)
                .HasConstraintName("FK_obra_colaborador_colaborador")
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(oc => oc.Cargo)
                .WithMany(c => c.ObraColaboradores)
                .HasForeignKey(oc => oc.CargoId)
                .HasConstraintName("FK_obra_colaborador_cargo")
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(oc => oc.Grupo)
                .WithMany(g => g.ObraColaboradores)
                .HasForeignKey(oc => oc.GrupoId)
                .HasConstraintName("FK_obra_colaborador_grupo")
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}