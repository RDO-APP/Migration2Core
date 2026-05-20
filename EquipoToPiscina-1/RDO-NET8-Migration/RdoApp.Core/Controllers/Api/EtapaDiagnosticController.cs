using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class EtapaDiagnosticController : ControllerBase
    {
        private readonly RdoContext _context;

        public EtapaDiagnosticController(RdoContext context)
        {
            _context = context;
        }

        [HttpGet("test-connection")]
        public async Task<IActionResult> TestConnection()
        {
            try
            {
                var canConnect = await _context.Database.CanConnectAsync();
                var database = _context.Database.GetDbConnection().Database;
                
                return Ok(new 
                { 
                    CanConnect = canConnect,
                    Database = database,
                    ConnectionString = _context.Database.GetDbConnection().ConnectionString.Replace("Pwd=rdoapp2018aws", "Pwd=***"),
                    Message = canConnect ? "✅ Database connection successful" : "❌ Database connection failed"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                { 
                    Error = ex.Message,
                    Message = "❌ Database connection error"
                });
            }
        }

        [HttpGet("test-etapa-count")]
        public async Task<IActionResult> TestEtapaCount()
        {
            try
            {
                var totalEtapas = await _context.Etapas.CountAsync();
                var etapasObra1 = await _context.Etapas.Where(e => e.ObraId == 1).CountAsync();
                
                // Get available obra IDs
                var obraIds = await _context.Etapas
                    .GroupBy(e => e.ObraId)
                    .Select(g => new { ObraId = g.Key, Count = g.Count() })
                    .OrderBy(g => g.ObraId)
                    .ToListAsync();

                return Ok(new 
                {
                    TotalEtapas = totalEtapas,
                    EtapasObra1 = etapasObra1,
                    AvailableObraIds = obraIds,
                    Message = etapasObra1 > 0 ? $"✅ Found {etapasObra1} etapas for ObraId=1" : "❌ No etapas found for ObraId=1"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                { 
                    Error = ex.Message,
                    StackTrace = ex.StackTrace,
                    Message = "❌ Etapa count query error"
                });
            }
        }

        [HttpGet("test-etapa-details/{obraId}")]
        public async Task<IActionResult> TestEtapaDetails(int obraId)
        {
            try
            {
                var etapas = await _context.Etapas
                    .Where(e => e.ObraId == obraId)
                    .Select(e => new 
                    {
                        Id = e.Id,
                        ObraId = e.ObraId,
                        Descricao = e.Descricao,
                        DescricaoLength = e.Descricao != null ? e.Descricao.Length : 0,
                        IsDescricaoNull = e.Descricao == null
                    })
                    .OrderBy(e => e.Id)
                    .ToListAsync();

                return Ok(new 
                {
                    ObraId = obraId,
                    Count = etapas.Count,
                    Etapas = etapas,
                    Message = etapas.Count > 0 ? $"✅ Found {etapas.Count} etapas for ObraId={obraId}" : $"❌ No etapas found for ObraId={obraId}"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                { 
                    Error = ex.Message,
                    StackTrace = ex.StackTrace,
                    Message = $"❌ Etapa details query error for ObraId={obraId}"
                });
            }
        }

        [HttpGet("test-include-tarefas/{obraId}")]
        public async Task<IActionResult> TestIncludeTarefas(int obraId)
        {
            try
            {
                var etapas = await _context.Etapas
                    .Include(e => e.Tarefas)
                    .Where(e => e.ObraId == obraId)
                    .Select(e => new 
                    {
                        Id = e.Id,
                        ObraId = e.ObraId,
                        Descricao = e.Descricao,
                        TarefaCount = e.Tarefas != null ? e.Tarefas.Count : 0,
                        IsTarefasNull = e.Tarefas == null
                    })
                    .OrderBy(e => e.Id)
                    .ToListAsync();

                return Ok(new 
                {
                    ObraId = obraId,
                    Count = etapas.Count,
                    Etapas = etapas,
                    TotalTarefas = etapas.Sum(e => e.TarefaCount),
                    Message = etapas.Count > 0 ? $"✅ Found {etapas.Count} etapas with {etapas.Sum(e => e.TarefaCount)} total tarefas for ObraId={obraId}" : $"❌ No etapas found for ObraId={obraId}"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                { 
                    Error = ex.Message,
                    StackTrace = ex.StackTrace,
                    Message = $"❌ Include tarefas query error for ObraId={obraId}"
                });
            }
        }

        [HttpGet("test-raw-sql/{obraId}")]
        public async Task<IActionResult> TestRawSql(int obraId)
        {
            try
            {
                // Execute raw SQL to bypass Entity Framework completely
                var sql = @"
                    SELECT 
                        eta_id_etapa as Id,
                        eta_id_obra as ObraId,
                        eta_ds_etapa as Descricao
                    FROM etapa 
                    WHERE eta_id_obra = {0}
                    ORDER BY eta_id_etapa";

                var results = await _context.Database
                    .SqlQueryRaw<EtapaRawResult>(sql, obraId)
                    .ToListAsync();

                return Ok(new 
                {
                    ObraId = obraId,
                    Count = results.Count,
                    Results = results,
                    Message = results.Count > 0 ? $"✅ Raw SQL found {results.Count} etapas for ObraId={obraId}" : $"❌ Raw SQL found no etapas for ObraId={obraId}"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                { 
                    Error = ex.Message,
                    StackTrace = ex.StackTrace,
                    Message = $"❌ Raw SQL query error for ObraId={obraId}"
                });
            }
        }
    }

    public class EtapaRawResult
    {
        public int Id { get; set; }
        public int ObraId { get; set; }
        public string? Descricao { get; set; }
    }
}