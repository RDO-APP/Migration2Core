using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Models.Entities;

namespace RdoApp.Core.Data.Configurations
{
    public class TarefaConfiguration : IEntityTypeConfiguration<Tarefa>
    {
        public void Configure(EntityTypeBuilder<Tarefa> builder)
        {
            builder.ToTable("tarefa");
            
            builder.HasKey(t => t.Id);
            
            // Propriedades básicas
            builder.Property(t => t.Id)
                .HasColumnName("tar_id_tarefa")
                .ValueGeneratedOnAdd();

            builder.Property(t => t.Agrupador)
                .HasColumnName("tar_nr_agrupador")
                .IsRequired();

            builder.Property(t => t.Descricao)
                .HasColumnName("tar_ds_tarefa")
                .HasMaxLength(500);

            builder.Property(t => t.DataInicio)
                .HasColumnName("tar_dt_inicio")
                .IsRequired();

            builder.Property(t => t.DataPrevisaoFim)
                .HasColumnName("tar_dt_previsao_fim");

            builder.Property(t => t.DataFim)
                .HasColumnName("tar_dt_fim");

            builder.Property(t => t.StatusId)
                .HasColumnName("tar_id_status")
                .IsRequired();

            builder.Property(t => t.EtapaId)
                .HasColumnName("tar_id_etapa")
                .IsRequired();

            builder.Property(t => t.UnidadeId)
                .HasColumnName("tar_id_unidade");

            builder.Property(t => t.QuantidadeConstruida)
                .HasColumnName("tar_nr_qtd_construida");

            builder.Property(t => t.QuantidadePrevisao)
                .HasColumnName("tar_nr_qtd_previsao");

            builder.Property(t => t.Comentario)
                .HasColumnName("tar_ds_comentario")
                .HasMaxLength(1000);

            builder.Property(t => t.Foto)
                .HasColumnName("tar_ds_foto")
                .HasMaxLength(500);

            builder.Property(t => t.HorasTrabalhadas)
                .HasColumnName("tar_nr_horas_trabalhadas");

            builder.Property(t => t.HoraMedicaoInicial)
                .HasColumnName("tar_dt_medicao_hora_inicial");

            builder.Property(t => t.HoraMedicaoFinal)
                .HasColumnName("tar_dt_medicao_hora_final");

            builder.Property(t => t.DataMedicao)
                .HasColumnName("tar_dt_medicao")
                .IsRequired();

            // REMOVED: tar_id_obra column doesn't exist in database
            // Tasks are linked to obras through etapas (tar_id_etapa -> eta_id_obra)
            // builder.Property(t => t.IdObra)
            //     .HasColumnName("tar_id_obra")
            //     .IsRequired();

            builder.Property(t => t.ValorUnitario)
                .HasColumnName("tar_vl_valor_unitario")
                .HasPrecision(18, 2);

            builder.Property(t => t.ColaboradorInsercaoId)
                .HasColumnName("tar_id_colaborador_insercao")
                .IsRequired();

            builder.Property(t => t.DataInsercao)
                .HasColumnName("tar_dt_insercao")
                .IsRequired();

            builder.Property(t => t.DataUltimaAtualizacao)
                .HasColumnName("tar_dt_ultima_atualizacao");

            builder.Property(t => t.HorimetroTotal)
                .HasColumnName("tar_dt_medicao_horimetro_total");

            builder.Property(t => t.HorimetroInicial)
                .HasColumnName("tar_dt_medicao_horimetro_inicial");

            builder.Property(t => t.HorimetroFinal)
                .HasColumnName("tar_dt_medicao_horimetro_final");

            builder.Property(t => t.CodigoParalizacao)
                .HasColumnName("tar_codigo_paralizacao")
                .HasMaxLength(50);

            // Water Quality Fields - Pool Management (8 fields)
            builder.Property(t => t.NivelCloro)
                .HasColumnName("tar_nr_nivel_cloro");

            builder.Property(t => t.Ph)
                .HasColumnName("tar_nr_ph");

            builder.Property(t => t.Alcalinidade)
                .HasColumnName("tar_nr_alcalinidade");

            builder.Property(t => t.Limpidez)
                .HasColumnName("tar_nr_limpidez");

            builder.Property(t => t.Superficie)
                .HasColumnName("tar_nr_superficie");

            builder.Property(t => t.Fundo)
                .HasColumnName("tar_nr_fundo");

            builder.Property(t => t.NivelDetritos)
                .HasColumnName("tar_nr_nivel_detritos");

            builder.Property(t => t.NivelProliferacao)
                .HasColumnName("tar_nr_nivel_proliferacao");

            // Relacionamentos - Day 7 Implementation
            builder.HasOne(t => t.Status)
                .WithMany(s => s.Tarefas)
                .HasForeignKey(t => t.StatusId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(t => t.Etapa)
                .WithMany(e => e.Tarefas)
                .HasForeignKey(t => t.EtapaId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasOne(t => t.ColaboradorInsercao)
                .WithMany(c => c.TarefasInseridas)
                .HasForeignKey(t => t.ColaboradorInsercaoId)
                .OnDelete(DeleteBehavior.Restrict);

            // Note: CodigoParalizacao is just a string field, not a foreign key relationship
            // This prevents Entity Framework from auto-creating phantom relationships
        }
    }
}
