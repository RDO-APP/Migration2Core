using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestUsuarioController : ControllerBase
    {
        private readonly RdoContext _context;
        private readonly ILogger<TestUsuarioController> _logger;

        public TestUsuarioController(RdoContext context, ILogger<TestUsuarioController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet("test-connection")]
        public async Task<IActionResult> TestConnection()
        {
            try
            {
                // Testar conexão básica do Entity Framework
                var connectionString = _context.Database.GetConnectionString();
                
                return Ok(new { 
                    sucesso = true, 
                    mensagem = "Controller funcionando",
                    connectionString = connectionString?.Substring(0, 50) + "..."
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao testar conexão");
                return StatusCode(500, new { erro = ex.Message, stack = ex.StackTrace });
            }
        }

        [HttpGet("test-raw-query")]
        public async Task<IActionResult> TestRawQuery()
        {
            try
            {
                // Executar query SQL direta na tabela colaborador
                var sql = @"
                    SELECT 
                        col_id,
                        col_nome,
                        col_cpf,
                        col_senha,
                        col_ativo
                    FROM colaborador 
                    WHERE col_cpf = '567.065.455-20'
                    LIMIT 1";

                var result = await _context.Database.SqlQueryRaw<dynamic>(sql).ToListAsync();

                return Ok(new { 
                    sucesso = true,
                    encontrado = result.Count > 0,
                    dados = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro na query SQL direta");
                return StatusCode(500, new { erro = ex.Message, stack = ex.StackTrace });
            }
        }

        [HttpGet("test-entity")]
        public async Task<IActionResult> TestEntity()
        {
            try
            {
                // Testar usando Entity Framework
                var usuario = await _context.Colaboradores
                    .Where(u => u.Cpf == "56706545520")
                    .FirstOrDefaultAsync();

                return Ok(new { 
                    sucesso = true,
                    encontrado = usuario != null,
                    usuario = usuario != null ? new {
                        id = usuario.Id,
                        nome = usuario.Nome,
                        cpf = usuario.Cpf,
                        ativo = usuario.Ativo
                    } : null
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao usar Entity Framework");
                return StatusCode(500, new { erro = ex.Message, stack = ex.StackTrace });
            }
        }

        [HttpGet("SearchByCpf")]
        public async Task<IActionResult> SearchByCpf(string cpf)
        {
            try
            {
                var usuario = await _context.Colaboradores
                    .Where(u => u.Cpf == cpf)
                    .FirstOrDefaultAsync();

                if (usuario == null)
                {
                    return Ok(new { 
                        found = false,
                        message = $"Usuário com CPF {cpf} não encontrado"
                    });
                }

                return Ok(new { 
                    found = true,
                    user = new {
                        id = usuario.Id,
                        nome = usuario.Nome,
                        cpf = usuario.Cpf,
                        email = usuario.Email,
                        telefone = usuario.Telefone,
                        ativo = usuario.Ativo,
                        senha = usuario.Senha
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar usuário por CPF {Cpf}", cpf);
                return StatusCode(500, new { erro = ex.Message });
            }
        }

        [HttpGet("Count")]
        public async Task<IActionResult> Count()
        {
            try
            {
                var count = await _context.Colaboradores.CountAsync();
                return Ok(new { count = count });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao contar colaboradores");
                return StatusCode(500, new { erro = ex.Message });
            }
        }

        [HttpGet("GetUserObras")]
        public async Task<IActionResult> GetUserObras(int userId)
        {
            try
            {
                var obras = await _context.Obras
                    .Include(o => o.Municipio)
                        .ThenInclude(m => m.Uf)
                    .Include(o => o.ObraColaboradores)
                        .ThenInclude(oc => oc.Grupo)
                    .Where(o => o.ObraColaboradores.Any(oc => oc.ColaboradorId == userId))
                    .Select(o => new
                    {
                        obraId = o.Id,
                        descricao = o.Descricao ?? "Obra sem nome",
                        grupoNome = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == userId)
                            .Select(oc => oc.Grupo.Nome)
                            .FirstOrDefault() ?? "BÁSICA"
                    })
                    .ToListAsync();

                return Ok(new { obras = obras });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao buscar obras do usuário {UserId}", userId);
                return StatusCode(500, new { erro = ex.Message });
            }
        }
    }
}