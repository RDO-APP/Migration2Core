using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Configuration for HistoricoLogin - uses composite key since legacy table has no primary key
/// </summary>
public class HistoricoLoginConfiguration : IEntityTypeConfiguration<HistoricoLogin>
{
    public void Configure(EntityTypeBuilder<HistoricoLogin> builder)
    {
        builder.ToTable("historico_login");
        
        // Composite key: worker + project + login date
        builder.HasKey(e => new { e.ColIdColaborador, e.ObrIdObra, e.DataLogin });
        
        builder.Property(e => e.ColIdColaborador).HasColumnName("col_id_colaborador").IsRequired();
        builder.Property(e => e.ColNrCpf).HasColumnName("col_nr_cpf").HasMaxLength(14).IsUnicode(false);
        builder.Property(e => e.ColNmColaborador).HasColumnName("col_nm_colaborador").HasMaxLength(100).IsUnicode(false);
        builder.Property(e => e.ColDsEmail).HasColumnName("col_ds_email").HasMaxLength(100).IsUnicode(false);
        builder.Property(e => e.ObrIdObra).HasColumnName("obr_id_obra");
        builder.Property(e => e.ObrDsObra).HasColumnName("obr_ds_obra").HasMaxLength(200).IsUnicode(false);
        builder.Property(e => e.DataLogin).HasColumnName("data_login").HasColumnType("datetime").IsRequired();
        
        builder.HasIndex(e => e.ColIdColaborador).HasDatabaseName("IX_historico_login_colaborador");
        builder.HasIndex(e => e.DataLogin).HasDatabaseName("IX_historico_login_data");
    }
}
