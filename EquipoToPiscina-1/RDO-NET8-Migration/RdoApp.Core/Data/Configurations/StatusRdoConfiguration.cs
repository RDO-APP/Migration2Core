using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class StatusRdoConfiguration : IEntityTypeConfiguration<StatusRdo>
    {
        public void Configure(EntityTypeBuilder<StatusRdo> builder)
        {
            builder.ToTable("status_rdo");
            
            builder.HasKey(s => s.Id);
            
            builder.Property(s => s.Id)
                .HasColumnName("str_id_status")
                .ValueGeneratedOnAdd();

            builder.Property(s => s.Descricao)
                .HasColumnName("str_ds_status")
                .HasMaxLength(100)
                .IsRequired();
        }
    }
}