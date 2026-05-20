using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class LaudoController : ControllerBase
    {
        private readonly ILaudoService _laudoService;

        public LaudoController(ILaudoService laudoService)
        {
            _laudoService = laudoService;
        }

        /// <summary>
        /// Get all laudos
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<LaudoDto>>> GetAll()
        {
            try
            {
                var laudos = await _laudoService.GetAllAsync();
                return Ok(laudos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Get laudo by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<LaudoDto>> GetById(int id)
        {
            try
            {
                var laudo = await _laudoService.GetByIdAsync(id);
                if (laudo == null)
                    return NotFound(new { message = "Laudo não encontrado" });

                return Ok(laudo);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Get laudos by obra ID
        /// </summary>
        [HttpGet("obra/{obraId}")]
        public async Task<ActionResult<IEnumerable<LaudoDto>>> GetByObraId(int obraId)
        {
            try
            {
                var laudos = await _laudoService.GetByObraIdAsync(obraId);
                return Ok(laudos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Get laudos by status ID
        /// </summary>
        [HttpGet("status/{statusId}")]
        public async Task<ActionResult<IEnumerable<LaudoDto>>> GetByStatusId(int statusId)
        {
            try
            {
                var laudos = await _laudoService.GetByStatusIdAsync(statusId);
                return Ok(laudos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Get laudos by date range
        /// </summary>
        [HttpGet("daterange")]
        public async Task<ActionResult<IEnumerable<LaudoDto>>> GetByDateRange(
            [FromQuery] DateTime dataInicial,
            [FromQuery] DateTime dataFinal)
        {
            try
            {
                var laudos = await _laudoService.GetByDateRangeAsync(dataInicial, dataFinal);
                return Ok(laudos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Create new laudo
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<LaudoDto>> Create([FromBody] CreateLaudoDto createDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var laudo = await _laudoService.CreateAsync(createDto);
                return CreatedAtAction(nameof(GetById), new { id = laudo.Id }, laudo);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Update laudo
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<LaudoDto>> Update(int id, [FromBody] UpdateLaudoDto updateDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var laudo = await _laudoService.UpdateAsync(id, updateDto);
                if (laudo == null)
                    return NotFound(new { message = "Laudo não encontrado" });

                return Ok(laudo);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Delete laudo
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                var success = await _laudoService.DeleteAsync(id);
                if (!success)
                    return NotFound(new { message = "Laudo não encontrado" });

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }

        /// <summary>
        /// Check if laudo exists for obra and date
        /// </summary>
        [HttpGet("exists")]
        public async Task<ActionResult<bool>> Exists([FromQuery] int obraId, [FromQuery] DateTime dataLaudo)
        {
            try
            {
                var exists = await _laudoService.ExistsAsync(obraId, dataLaudo);
                return Ok(new { exists });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
    }
}