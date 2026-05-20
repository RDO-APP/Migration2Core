using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class HistoricoTarefaColaboradorConfiguration : IEntityTypeConfiguration<HistoricoTarefaColaborador>
{
    public void Configure(EntityTypeBuilder<HistoricoTarefaColaborador> builder)
    {
        builder.ToTable("historico_tarefa_colaborador");
        builder.HasKey(e => e.HtcIdTarefaColaborador);
        builder.Property(e => e.HtcIdTarefaColaborador).HasColumnName("htc_id_tarefa_colaborador").ValueGeneratedOnAdd();
        builder.Property(e => e.HtcIdHistoricoTarefaRdo).HasColumnName("htc_id_historico_tarefa_rdo").IsRequired();
        builder.Property(e => e.HtcIdObraColaborador).HasColumnName("htc_id_obra_colaborador").IsRequired();
        
        builder.HasIndex(e => e.HtcIdHistoricoTarefaRdo).HasDatabaseName("IX_historico_tarefa_colaborador_historico");
        builder.HasIndex(e => e.HtcIdObraColaborador).HasDatabaseName("IX_historico_tarefa_colaborador_obra_colaborador");
    }
}
