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
    private readonly HorasEquipamentoReportService _horas;
    private readonly TarefaStatusUpdateService _status;

    public BffTarefasController(
        TarefaCadastroQueryService query,
        TarefaCadastroSaveService save,
        HorasEquipamentoReportService horas,
        TarefaStatusUpdateService status)
    {
        _query = query;
        _save = save;
        _horas = horas;
        _status = status;
    }

    [HttpGet("novo")]
    public async Task<IActionResult> GetNovo([FromQuery] int? etapaId, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        try
        {
            var payload = await _query.GetBlankAsync(obraId, etapaId, cancellationToken);
            return Ok(payload);
        }
        catch (Exception ex)
        {
            var inner = ex.InnerException?.Message;
            var detail = string.IsNullOrWhiteSpace(inner) ? ex.Message : $"{ex.Message} | {inner}";
            return StatusCode(500, new { message = $"Erro 500 no servidor (nova tarefa). {ex.GetType().Name}: {detail}" });
        }
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

    [HttpPost("{id:int}/relatorio-horas-equipamento")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> RelatorioHoras(
        int id,
        [FromBody] HorasEquipamentoReportRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null)
        {
            return BadRequest(new { message = "Corpo da requisição inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        try
        {
            var file = await _horas.GenerateAsync(obraId, id, body, cancellationToken);
            return File(file.Bytes, file.ContentType, file.FileName);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            var inner = ex.InnerException?.Message;
            var detail = string.IsNullOrWhiteSpace(inner) ? ex.Message : $"{ex.Message} | {inner}";
            return StatusCode(500, new { message = $"Erro ao gerar relatório. {ex.GetType().Name}: {detail}" });
        }
    }


    [HttpPost("{id:int}/status")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> AtualizarStatus(
        int id,
        [FromBody] TarefaStatusUpdateRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null || body.IdStatus <= 0)
        {
            return BadRequest(new TarefaStatusUpdateResultDto { Ok = false, ErrorMessage = "Status inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var colaboradorId = LoginSessionHelper.GetColaboradorId(HttpContext);
        try
        {
            var result = await _status.AtualizarAsync(obraId, colaboradorId, id, body.IdStatus, cancellationToken);
            if (!result.Ok)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new TarefaStatusUpdateResultDto { Ok = false, ErrorMessage = ex.Message });
        }
    }

    [HttpPost("status-em-massa")]
    [IgnoreAntiforgeryToken]
    public async Task<IActionResult> AtualizarStatusEmMassa(
        [FromBody] TarefaStatusMassaRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null || body.IdStatus <= 0)
        {
            return BadRequest(new TarefaStatusMassaResultDto { Ok = false, ErrorMessage = "Status inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var colaboradorId = LoginSessionHelper.GetColaboradorId(HttpContext);
        try
        {
            var result = await _status.AtualizarEmMassaAsync(
                obraId, colaboradorId, body.Ids ?? Array.Empty<int>(), body.IdStatus, cancellationToken);
            if (!result.Ok)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new TarefaStatusMassaResultDto { Ok = false, ErrorMessage = ex.Message });
        }
    }
}
