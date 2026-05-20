using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    public class ObraService : IObraService
    {
        private readonly RdoContext _context;
        private readonly ILogger<ObraService> _logger;

        public ObraService(RdoContext context, ILogger<ObraService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<List<ObraViewModel>> ObterObrasAsync(int colaboradorId)
        {
            try
            {
                _logger.LogInformation("Loading obras for colaborador ID: {ColaboradorId}", colaboradorId);

                var obras = await _context.Obras
                    .Include(o => o.Municipio)
                        .ThenInclude(m => m.Uf)
                    .Include(o => o.ObraColaboradores)
                        .ThenInclude(oc => oc.Grupo)
                    .Where(o => o.ObraColaboradores.Any(oc => oc.ColaboradorId == colaboradorId))
                    .Select(o => new ObraViewModel
                    {
                        Id = o.Id,
                        Descricao = o.Descricao ?? "Obra sem nome",
                        CidadeEstado = o.Municipio.Descricao + "/" + o.Municipio.Uf.Sigla,
                        StatusBasicaGratuita = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == colaboradorId)
                            .Select(oc => oc.Grupo.Nome)
                            .FirstOrDefault() ?? "BÁSICA",
                        ContratanteContratada = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == colaboradorId)
                            .Select(oc => oc.Grupo.StatusContratante == 1 ? "contratante" : "contratada")
                            .FirstOrDefault() ?? "contratada",
                        ProgressoPorcentagem = CalcularProgressoPorcentagem(o.DataInicio, o.DataPrevisaoFim),
                        ClasseStatusCss = DeterminarClasseStatusCss(o.DataInicio, o.DataPrevisaoFim, o.DataFim),
                        DataInicio = o.DataInicio.ToString("dd/MM/yyyy"),
                        DataConclusao = o.DataFim.HasValue ? o.DataFim.Value.ToString("dd/MM/yyyy") : "",
                        ObraFinalizada = !o.DataFim.HasValue || o.DataFim == DateTime.MinValue
                    })
                    .ToListAsync();

                _logger.LogInformation("Found {Count} obras for colaborador {ColaboradorId}", obras.Count, colaboradorId);
                return obras;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading obras for colaborador {ColaboradorId}", colaboradorId);
                return new List<ObraViewModel>();
            }
        }

        public async Task<List<object>> ObterEtapasAsync(int obraId)
        {
            try
            {
                _logger.LogInformation("Loading etapas for obra {ObraId}", obraId);

                var etapas = await _context.Etapas
                    .Include(e => e.Tarefas)
                        .ThenInclude(t => t.Status)
                    .Where(e => e.ObraId == obraId)
                    .Select(e => new
                    {
                        Id = e.Id,
                        Titulo = e.Descricao,
                        IdObra = e.ObraId,
                        Tarefas = e.Tarefas.Select(t => new
                        {
                            Id = t.Id,
                            Descricao = t.Descricao,
                            DataInicio = t.DataInicio,
                            DataPrevisaoFim = t.DataPrevisaoFim,
                            DataFim = t.DataFim,
                            DataMedicao = t.DataMedicao,
                            QuantidadeConstruida = t.QuantidadeConstruida,
                            StatusDescricao = t.Status != null ? t.Status.Descricao : "Planejada"
                        }).ToList()
                    })
                    .ToListAsync();

                _logger.LogInformation("Found {Count} etapas for obra {ObraId}", etapas.Count, obraId);
                return etapas.Cast<object>().ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading etapas for obra {ObraId}: {Message}", obraId, ex.Message);
                return new List<object>();
            }
        }

        private static int CalcularProgressoPorcentagem(DateTime dataInicio, DateTime? dataPrevisaoFim)
        {
            if (!dataPrevisaoFim.HasValue) return 0;

            DateTime inicio = dataInicio;
            DateTime fim = dataPrevisaoFim.Value;
            DateTime atual = DateTime.Now;

            double total = fim.Subtract(inicio).Days;
            double decorrido = atual.Subtract(inicio).Days;

            if (atual >= fim)
            {
                return 100;
            }
            else if (atual < inicio)
            {
                return 0;
            }

            int result = Convert.ToInt32(Math.Round(100 / total * decorrido, 2));
            return result;
        }

        private static string DeterminarClasseStatusCss(DateTime dataInicio, DateTime? dataPrevisaoFim, DateTime? dataFim)
        {
            int progresso = CalcularProgressoPorcentagem(dataInicio, dataPrevisaoFim);

            if (progresso == 100)
            {
                if (dataFim.HasValue && dataPrevisaoFim.HasValue)
                {
                    if (dataFim.Value > dataPrevisaoFim.Value)
                    {
                        return "bg-vermelho";
                    }
                    return "bg-verde";
                }

                if (!dataFim.HasValue && DateTime.Now > dataPrevisaoFim)
                {
                    return "bg-vermelho";
                }

                return "bg-verde";
            }

            return "bg-cinza";
        }

        public async Task<ObraViewModel?> ObterObraPorIdAsync(int obraId)
        {
            try
            {
                _logger.LogInformation("Loading obra by ID: {ObraId}", obraId);

                var obra = await _context.Obras
                    .Include(o => o.Municipio)
                        .ThenInclude(m => m.Uf)
                    .Where(o => o.Id == obraId)
                    .Select(o => new ObraViewModel
                    {
                        Id = o.Id,
                        Descricao = o.Descricao ?? "Obra sem nome",
                        CidadeEstado = o.Municipio.Descricao + "/" + o.Municipio.Uf.Sigla,
                        ProgressoPorcentagem = CalcularProgressoPorcentagem(o.DataInicio, o.DataPrevisaoFim),
                        ClasseStatusCss = DeterminarClasseStatusCss(o.DataInicio, o.DataPrevisaoFim, o.DataFim),
                        DataInicio = o.DataInicio.ToString("dd/MM/yyyy"),
                        DataConclusao = o.DataFim.HasValue ? o.DataFim.Value.ToString("dd/MM/yyyy") : "",
                        ObraFinalizada = !o.DataFim.HasValue || o.DataFim == DateTime.MinValue
                    })
                    .FirstOrDefaultAsync();

                _logger.LogInformation("Found obra: {ObraDescricao}", obra?.Descricao ?? "Not found");
                return obra;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading obra by ID {ObraId}", obraId);
                return null;
            }
        }
    }
}