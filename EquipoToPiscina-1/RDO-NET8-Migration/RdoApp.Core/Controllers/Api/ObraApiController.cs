using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.Entities;
using System.Security.Claims;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class ObraApiController : ControllerBase
    {
        private readonly RdoContext _context;
        private readonly ILogger<ObraApiController> _logger;

        public ObraApiController(RdoContext context, ILogger<ObraApiController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost("ObterObras")]
        public async Task<ActionResult<List<object>>> ObterObras([FromBody] dynamic param)
        {
            try
            {
                // IMPROVEMENT 3: Use Claims-based authentication instead of hardcoded ID
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int idColaborador))
                {
                    _logger.LogWarning("Invalid or missing user ID claim");
                    return Unauthorized(new { error = "User not authenticated or invalid user ID" });
                }
                
                _logger.LogInformation("Using authenticated colaborador ID: {IdColaborador}", idColaborador);

                // Query obras following Gilberto's pattern
                var obras = await _context.Obras
                    .Include(o => o.Municipio)
                        .ThenInclude(m => m.Uf)
                    .Include(o => o.ObraColaboradores)
                        .ThenInclude(oc => oc.Grupo)
                    .Where(o => o.ObraColaboradores.Any(oc => oc.ColaboradorId == idColaborador))
                    .Select(o => new
                    {
                        IdObra = o.Id,
                        Descricao = o.Descricao ?? "Obra sem nome",
                        CidadeEstado = o.Municipio.Descricao + "/" + o.Municipio.Uf.Sigla,
                        StatusBasicaGratuita = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == idColaborador)
                            .Select(oc => oc.Grupo.Nome)
                            .FirstOrDefault() ?? "BÁSICA",
                        ContratanteContratada = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == idColaborador)
                            .Select(oc => oc.Grupo.StatusContratante == 1 ? "contratante" : "contratada")
                            .FirstOrDefault() ?? "contratada",
                        ProgressoPorcentagem = CalcularProgressoPorcentagem(o.DataInicio, o.DataPrevisaoFim),
                        ClasseStatusCss = DeterminarClasseStatusCss(o.DataInicio, o.DataPrevisaoFim, o.DataFim),
                        DataInicio = o.DataInicio.ToString("dd/MM/yyyy"),
                        DataConclusao = o.DataFim.HasValue ? o.DataFim.Value.ToString("dd/MM/yyyy") : "",
                        ObraFinalizada = !o.DataFim.HasValue || o.DataFim == DateTime.MinValue
                    })
                    .ToListAsync();

                return Ok(obras);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao obter obras para colaborador");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("Etapas/{obraId}")]
        public async Task<ActionResult<List<object>>> ObterEtapas(int obraId)
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

                return Ok(etapas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DETAILED ERROR loading etapas for obra {ObraId}: {Message}", obraId, ex.Message);
                return StatusCode(500, new { error = ex.Message, details = ex.ToString() });
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
    }
}