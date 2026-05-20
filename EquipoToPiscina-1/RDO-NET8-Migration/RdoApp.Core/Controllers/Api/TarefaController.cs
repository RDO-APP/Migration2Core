using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TarefaController : ControllerBase
    {
        private readonly ITarefaService _tarefaService;
        private readonly ILogger<TarefaController> _logger;

        public TarefaController(ITarefaService tarefaService, ILogger<TarefaController> logger)
        {
            _tarefaService = tarefaService;
            _logger = logger;
        }

        /// <summary>
        /// Obtém todas as tarefas
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TarefaDto>>> GetAll()
        {
            try
            {
                var tarefas = await _tarefaService.GetAllAsync();
                return Ok(tarefas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar todas as tarefas");
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Obtém uma tarefa por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<TarefaDto>> GetById(int id)
        {
            try
            {
                var tarefa = await _tarefaService.GetByIdAsync(id);
                if (tarefa == null)
                    return NotFound(new { message = "Tarefa não encontrada" });

                return Ok(tarefa);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar tarefa com ID {Id}", id);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Obtém tarefas paginadas com filtros
        /// </summary>
        [HttpPost("search")]
        public async Task<ActionResult<PagedResult<TarefaDto>>> GetPaged([FromBody] TarefaFilterDto filter)
        {
            try
            {
                var result = await _tarefaService.GetPagedAsync(filter);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar tarefas paginadas");
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Obtém tarefas por obra
        /// </summary>
        [HttpGet("obra/{obraId}")]
        public async Task<ActionResult<IEnumerable<TarefaDto>>> GetByObra(int obraId)
        {
            try
            {
                var tarefas = await _tarefaService.GetByObraIdAsync(obraId);
                return Ok(tarefas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar tarefas da obra {ObraId}", obraId);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Obtém tarefas por status
        /// </summary>
        [HttpGet("status/{statusId}")]
        public async Task<ActionResult<IEnumerable<TarefaDto>>> GetByStatus(int statusId)
        {
            try
            {
                var tarefas = await _tarefaService.GetByStatusAsync(statusId);
                return Ok(tarefas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar tarefas com status {StatusId}", statusId);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Cria uma nova tarefa
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<TarefaDto>> Create([FromBody] CreateTarefaDto createDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var tarefa = await _tarefaService.CreateAsync(createDto);
                return CreatedAtAction(nameof(GetById), new { id = tarefa.Id }, tarefa);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao criar tarefa");
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Atualiza uma tarefa existente
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<TarefaDto>> Update(int id, [FromBody] UpdateTarefaDto updateDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var tarefa = await _tarefaService.UpdateAsync(id, updateDto);
                return Ok(tarefa);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Tarefa não encontrada para atualização: {Id}", id);
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao atualizar tarefa {Id}", id);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Remove uma tarefa
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                var success = await _tarefaService.DeleteAsync(id);
                if (!success)
                    return NotFound(new { message = "Tarefa não encontrada" });

                return NoContent();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao deletar tarefa {Id}", id);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }

        /// <summary>
        /// Obtém histórico de uma tarefa
        /// </summary>
        [HttpGet("{id}/historico")]
        public async Task<ActionResult<IEnumerable<TarefaHistoricoDto>>> GetHistorico(int id)
        {
            try
            {
                var historico = await _tarefaService.GetHistoricoAsync(id);
                return Ok(historico);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar histórico da tarefa {Id}", id);
                return StatusCode(500, new { message = "Erro interno do servidor" });
            }
        }
    }
}