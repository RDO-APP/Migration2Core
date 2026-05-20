using Microsoft.AspNetCore.Mvc;
using MySqlConnector;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TesteBancoController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public TesteBancoController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet("conexao")]
        public async Task<ActionResult> TestarConexao()
        {
            try
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();
                
                return Ok(new { 
                    message = "Conexão com banco antigo OK!", 
                    database = connection.Database,
                    server = connection.DataSource
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    message = "Erro na conexão", 
                    error = ex.Message 
                });
            }
        }

        [HttpGet("tabelas")]
        public async Task<ActionResult> ListarTabelas()
        {
            try
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();
                
                using var command = new MySqlCommand("SHOW TABLES", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                var tabelas = new List<string>();
                while (await reader.ReadAsync())
                {
                    tabelas.Add(reader.GetString(0));
                }
                
                return Ok(new { 
                    message = "Tabelas encontradas", 
                    total = tabelas.Count,
                    tabelas = tabelas.Take(10) // Primeiras 10
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    message = "Erro ao listar tabelas", 
                    error = ex.Message 
                });
            }
        }

        [HttpGet("tarefa-count")]
        public async Task<ActionResult> ContarTarefas()
        {
            try
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();
                
                using var command = new MySqlCommand("SELECT COUNT(*) FROM tarefa", connection);
                var count = await command.ExecuteScalarAsync();
                
                return Ok(new { 
                    message = "Tarefas encontradas", 
                    total = count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    message = "Erro ao contar tarefas", 
                    error = ex.Message 
                });
            }
        }

        [HttpGet("tarefa-sample")]
        public async Task<ActionResult> BuscarTarefasSample()
        {
            try
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();
                
                using var command = new MySqlCommand("SELECT tar_id_tarefa, tar_ds_tarefa, tar_dt_inicio FROM tarefa LIMIT 5", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                var tarefas = new List<object>();
                while (await reader.ReadAsync())
                {
                    tarefas.Add(new {
                        id = reader.GetInt32("tar_id_tarefa"),
                        descricao = reader.IsDBNull(reader.GetOrdinal("tar_ds_tarefa")) ? "N/A" : reader.GetString("tar_ds_tarefa"),
                        dataInicio = reader.GetDateTime("tar_dt_inicio")
                    });
                }
                
                return Ok(new { 
                    message = "Primeiras 5 tarefas", 
                    tarefas = tarefas
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    message = "Erro ao buscar tarefas", 
                    error = ex.Message 
                });
            }
        }
    }
}