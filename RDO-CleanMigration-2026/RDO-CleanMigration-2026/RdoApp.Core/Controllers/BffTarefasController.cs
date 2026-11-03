using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/tarefas")]
public class BffTarefasController : ControllerBase
{
    private readonly TarefaCadastroQueryService _query;
    private readonly TarefaCadastroSaveService _save;

    public BffTarefasController(TarefaCadastroQueryService query, TarefaCadastroSaveService save)
    {
        _query = query;
        _save = save;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        try
        {
            var payload = await _query.GetAsync(obraId, id, cancellationToken);
            if (payload == null)
            {
                return NotFound(new { message = "Tarefa não encontrada nesta obra." });
            }

            return Ok(payload);
        }
        catch (Exception ex)
        {
            var inner = ex.InnerException?.Message;
            var detail = string.IsNullOrWhiteSpace(inner) ? ex.Message : $"{ex.Message} | {inner}";
            return StatusCode(500, new { message = $"Erro 500 no servidor (tarefa). {ex.GetType().Name}: {detail}" });
        }
    }

    [HttpPost]
    public async Task<IActionResult> Save(
        [FromBody] TarefaCadastroSaveRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null)
        {
            return BadRequest(new TarefaCadastroSaveResultDto { Ok = false, ErrorMessage = "Corpo da requisição inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var colaboradorId = LoginSessionHelper.GetColaboradorId(HttpContext);
        TarefaCadastroSaveResultDto result;
        try
        {
            result = await _save.SaveAsync(obraId, colaboradorId, body, cancellationToken);
        }
        catch (Exception ex)
        {
            return BadRequest(new TarefaCadastroSaveResultDto { Ok = false, ErrorMessage = ex.Message });
        }

        if (!result.Ok)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }
}
