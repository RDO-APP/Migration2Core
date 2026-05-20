using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class RdoController : ControllerBase
    {
        private readonly IRdoService _rdoService;
        
        public RdoController(IRdoService rdoService)
        {
            _rdoService = rdoService;
        }
        
        /// <summary>
        /// Get all RDOs
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<RdoDto>>> GetAll()
        {
            try
            {
                var rdos = await _rdoService.GetAllAsync();
                return Ok(rdos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Get RDO by ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<RdoDto>> GetById(int id)
        {
            try
            {
                var rdo = await _rdoService.GetByIdAsync(id);
                if (rdo == null)
                    return NotFound(new { message = $"RDO com ID {id} não encontrado" });
                return Ok(rdo);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Get RDOs by Obra ID
        /// </summary>
        [HttpGet("obra/{obraId}")]
        public async Task<ActionResult<IEnumerable<RdoDto>>> GetByObra(int obraId)
        {
            try
            {
                var rdos = await _rdoService.GetByObraIdAsync(obraId);
                return Ok(rdos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Get RDOs by date range
        /// </summary>
        [HttpGet("daterange")]
        public async Task<ActionResult<IEnumerable<RdoDto>>> GetByDateRange(
            [FromQuery] DateTime startDate, 
            [FromQuery] DateTime endDate)
        {
            try
            {
                if (startDate > endDate)
                    return BadRequest(new { message = "Data inicial não pode ser maior que data final" });
                
                var rdos = await _rdoService.GetByDateRangeAsync(startDate, endDate);
                return Ok(rdos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Create new RDO
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<RdoDto>> Create(CreateRdoDto createDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);
                
                var rdo = await _rdoService.CreateAsync(createDto);
                return CreatedAtAction(nameof(GetById), new { id = rdo.Id }, rdo);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Update RDO
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<RdoDto>> Update(int id, UpdateRdoDto updateDto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);
                
                var rdo = await _rdoService.UpdateAsync(id, updateDto);
                if (rdo == null)
                    return NotFound(new { message = $"RDO com ID {id} não encontrado" });
                return Ok(rdo);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Delete RDO
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                var success = await _rdoService.DeleteAsync(id);
                if (!success)
                    return NotFound(new { message = $"RDO com ID {id} não encontrado" });
                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
        
        /// <summary>
        /// Check if RDO exists for obra and date
        /// </summary>
        [HttpGet("exists")]
        public async Task<ActionResult<bool>> Exists([FromQuery] int obraId, [FromQuery] DateTime data)
        {
            try
            {
                var exists = await _rdoService.ExistsAsync(obraId, data);
                return Ok(new { exists, obraId, data = data.ToString("dd/MM/yyyy") });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Erro interno do servidor", error = ex.Message });
            }
        }
    }
}