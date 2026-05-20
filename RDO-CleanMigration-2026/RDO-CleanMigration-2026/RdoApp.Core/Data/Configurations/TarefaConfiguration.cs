using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Tarefa (Task) entity
/// </summary>
public class TarefaConfiguration : IEntityTypeConfiguration<Tarefa>
{
    public void Configure(EntityTypeBuilder<Tarefa> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("tarefa");

        // Primary key
        builder.HasKey(t => t.TarIdTarefa);
        builder.Property(t => t.TarIdTarefa)
            .HasColumnName("tar_id_tarefa")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(t => t.TarIdStatus)
            .HasColumnName("tar_id_status")
            .IsRequired();

        builder.Property(t => t.TarIdEtapa)
            .HasColumnName("tar_id_etapa")
            .IsRequired();

        builder.Property(t => t.TarIdUnidade)
            .HasColumnName("tar_id_unidade");

        builder.Property(t => t.TarIdColaboradorInsercao)
            .HasColumnName("tar_id_colaborador_insercao")
            .IsRequired();

        builder.Property(t => t.TarCodigoParalizacao)
            .HasColumnName("tar_codigo_paralizacao")
            .HasMaxLength(50);

        // Properties
        builder.Property(t => t.TarNrAgrupador)
            .HasColumnName("tar_nr_agrupador")
            .IsRequired();

        builder.Property(t => t.TarDsTarefa)
            .HasColumnName("tar_ds_tarefa")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(t => t.TarNrQtdConstruida)
            .HasColumnName("tar_nr_qtd_construida");

        builder.Property(t => t.TarDtInicio)
            .HasColumnName("tar_dt_inicio")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(t => t.TarDtPrevisaoFim)
            .HasColumnName("tar_dt_previsao_fim")
            .HasColumnType("datetime");

        builder.Property(t => t.TarDtFim)
            .HasColumnName("tar_dt_fim")
            .HasColumnType("datetime");

        builder.Property(t => t.TarDsComentario)
            .HasColumnName("tar_ds_comentario")
            .HasMaxLength(1000)
            .IsRequired();

        builder.Property(t => t.TarDsFoto)
            .HasColumnName("tar_ds_foto")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(t => t.TarNrHorasTrabalhadas)
            .HasColumnName("tar_nr_horas_trabalhadas");

        builder.Property(t => t.TarDtMedicaoHoraFinal)
            .HasColumnName("tar_dt_medicao_hora_final");

        builder.Property(t => t.TarDtMedicaoHoraInicial)
            .HasColumnName("tar_dt_medicao_hora_inicial");

        builder.Property(t => t.TarDtMedicao)
            .HasColumnName("tar_dt_medicao")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(t => t.TarVlValorUnitario)
            .HasColumnName("tar_vl_valor_unitario")
            .HasColumnType("decimal(18,2)");

        builder.Property(t => t.TarDtInsercao)
            .HasColumnName("tar_dt_insercao")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(t => t.TarDtUltimaAtualizacao)
            .HasColumnName("tar_dt_ultima_atualizacao")
            .HasColumnType("datetime");

        builder.Property(t => t.TarNrQtdPrevisao)
            .HasColumnName("tar_nr_qtd_previsao")
            .HasColumnType("decimal(18,2)");

        builder.Property(t => t.TarDtMedicaoHorimetroTotal)
            .HasColumnName("tar_dt_medicao_horimetro_total");

        builder.Property(t => t.TarDtMedicaoHorimetroInicial)
            .HasColumnName("tar_dt_medicao_horimetro_inicial");

        builder.Property(t => t.TarDtMedicaoHorimetroFinal)
            .HasColumnName("tar_dt_medicao_horimetro_final");

        // Indexes
        builder.HasIndex(t => t.TarIdEtapa);
        builder.HasIndex(t => t.TarIdStatus);
        builder.HasIndex(t => t.TarIdUnidade);
        builder.HasIndex(t => t.TarIdColaboradorInsercao);
        builder.HasIndex(t => t.TarNrAgrupador); // Important for grouping tasks
        builder.HasIndex(t => t.TarDtInicio);
        builder.HasIndex(t => t.TarCodigoParalizacao);
    }
}
