using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestConnectionController : ControllerBase
    {
        private readonly RdoContext _context;
        private readonly ILogger<TestConnectionController> _logger;

        public TestConnectionController(RdoContext context, ILogger<TestConnectionController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet("database")]
        public async Task<IActionResult> TestDatabase()
        {
            try
            {
                // Testar conexão básica
                var canConnect = await _context.Database.CanConnectAsync();
                
                if (!canConnect)
                {
                    return BadRequest(new { 
                        sucesso = false, 
                        mensagem = "Não foi possível conectar ao banco de dados" 
                    });
                }

                // Contar colaboradores
                var totalColaboradores = await _context.Colaboradores.CountAsync();

                return Ok(new { 
                    sucesso = true, 
                    mensagem = "Conexão com banco OK",
                    totalColaboradores = totalColaboradores,
                    connectionString = _context.Database.GetConnectionString()?.Substring(0, 50) + "..."
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao testar conexão com banco");
                return StatusCode(500, new { 
                    sucesso = false, 
                    mensagem = "Erro interno: " + ex.Message 
                });
            }
        }

        [HttpGet("usuario/{cpf}")]
        public async Task<IActionResult> TestUsuario(string cpf)
        {
            try
            {
                var usuario = await _context.Colaboradores
                    .Where(u => u.Cpf == cpf)
                    .FirstOrDefaultAsync();

                if (usuario == null)
                {
                    return NotFound(new { 
                        sucesso = false, 
                        mensagem = $"Usuário com CPF {cpf} não encontrado" 
                    });
                }

                return Ok(new { 
                    sucesso = true, 
                    usuario = new {
                        id = usuario.Id,
                        nome = usuario.Nome,
                        cpf = usuario.Cpf,
                        ativo = usuario.Ativo
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar usuário {Cpf}", cpf);
                return StatusCode(500, new { 
                    sucesso = false, 
                    mensagem = "Erro interno: " + ex.Message 
                });
            }
        }
    }
}