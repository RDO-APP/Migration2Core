using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    public class RdoService : IRdoService
    {
        private readonly RdoContext _context;
        
        public RdoService(RdoContext context)
        {
            _context = context;
        }
        
        public async Task<IEnumerable<RdoDto>> GetAllAsync()
        {
            return await _context.Rdos
                .Include(r => r.Obra)
                .Include(r => r.Colaborador)
                .Include(r => r.RdoTarefas)
                    .ThenInclude(rt => rt.Tarefa)
                .Select(r => new RdoDto
                {
                    Id = r.Id,
                    ObraId = r.ObraId,
                    ColaboradorId = r.ColaboradorId,
                    Data = r.Data,
                    Observacao = r.Observacao,
                    Temperatura = r.Temperatura,
                    CondicoesTempo = r.CondicoesTempo,
                    Status = r.Status,
                    DataCriacao = r.DataCriacao,
                    DataAtualizacao = r.DataAtualizacao,
                    ObraNome = r.Obra != null ? r.Obra.Descricao : null,
                    ColaboradorNome = r.Colaborador != null ? r.Colaborador.Nome : null,
                    TotalTarefas = r.RdoTarefas != null ? r.RdoTarefas.Count : 0
                })
                .ToListAsync();
        }
        
        public async Task<RdoDto?> GetByIdAsync(int id)
        {
            return await _context.Rdos
                .Include(r => r.Obra)
                .Include(r => r.Colaborador)
                .Include(r => r.RdoTarefas)
                    .ThenInclude(rt => rt.Tarefa)
                .Where(r => r.Id == id)
                .Select(r => new RdoDto
                {
                    Id = r.Id,
                    ObraId = r.ObraId,
                    ColaboradorId = r.ColaboradorId,
                    Data = r.Data,
                    Observacao = r.Observacao,
                    Temperatura = r.Temperatura,
                    CondicoesTempo = r.CondicoesTempo,
                    Status = r.Status,
                    DataCriacao = r.DataCriacao,
                    DataAtualizacao = r.DataAtualizacao,
                    ObraNome = r.Obra != null ? r.Obra.Descricao : null,
                    ColaboradorNome = r.Colaborador != null ? r.Colaborador.Nome : null,
                    TotalTarefas = r.RdoTarefas != null ? r.RdoTarefas.Count : 0
                })
                .FirstOrDefaultAsync();
        }
        
        public async Task<IEnumerable<RdoDto>> GetByObraIdAsync(int obraId)
        {
            return await _context.Rdos
                .Include(r => r.Obra)
                .Include(r => r.Colaborador)
                .Include(r => r.RdoTarefas)
                    .ThenInclude(rt => rt.Tarefa)
                .Where(r => r.ObraId == obraId)
                .Select(r => new RdoDto
                {
                    Id = r.Id,
                    ObraId = r.ObraId,
                    ColaboradorId = r.ColaboradorId,
                    Data = r.Data,
                    Observacao = r.Observacao,
                    Temperatura = r.Temperatura,
                    CondicoesTempo = r.CondicoesTempo,
                    Status = r.Status,
                    DataCriacao = r.DataCriacao,
                    DataAtualizacao = r.DataAtualizacao,
                    ObraNome = r.Obra != null ? r.Obra.Descricao : null,
                    ColaboradorNome = r.Colaborador != null ? r.Colaborador.Nome : null,
                    TotalTarefas = r.RdoTarefas != null ? r.RdoTarefas.Count : 0
                })
                .OrderByDescending(r => r.Data)
                .ToListAsync();
        }
        
        public async Task<IEnumerable<RdoDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate)
        {
            return await _context.Rdos
                .Include(r => r.Obra)
                .Include(r => r.Colaborador)
                .Include(r => r.RdoTarefas)
                    .ThenInclude(rt => rt.Tarefa)
                .Where(r => r.Data >= startDate && r.Data <= endDate)
                .Select(r => new RdoDto
                {
                    Id = r.Id,
                    ObraId = r.ObraId,
                    ColaboradorId = r.ColaboradorId,
                    Data = r.Data,
                    Observacao = r.Observacao,
                    Temperatura = r.Temperatura,
                    CondicoesTempo = r.CondicoesTempo,
                    Status = r.Status,
                    DataCriacao = r.DataCriacao,
                    DataAtualizacao = r.DataAtualizacao,
                    ObraNome = r.Obra != null ? r.Obra.Descricao : null,
                    ColaboradorNome = r.Colaborador != null ? r.Colaborador.Nome : null,
                    TotalTarefas = r.RdoTarefas != null ? r.RdoTarefas.Count : 0
                })
                .OrderByDescending(r => r.Data)
                .ToListAsync();
        }
        
        public async Task<RdoDto> CreateAsync(CreateRdoDto createDto)
        {
            // Business validation - prevent duplicate RDO for same obra/date
            var exists = await ExistsAsync(createDto.ObraId, createDto.Data);
            if (exists)
            {
                throw new InvalidOperationException($"RDO já existe para a obra {createDto.ObraId} na data {createDto.Data:dd/MM/yyyy}");
            }
            
            var rdo = new Rdo
            {
                ObraId = createDto.ObraId,
                ColaboradorId = createDto.ColaboradorId,
                Data = createDto.Data,
                Observacao = createDto.Observacao,
                Temperatura = createDto.Temperatura,
                CondicoesTempo = createDto.CondicoesTempo,
                Status = createDto.Status ?? "Aberto",
                DataCriacao = DateTime.Now
            };
            
            _context.Rdos.Add(rdo);
            await _context.SaveChangesAsync();
            
            return await GetByIdAsync(rdo.Id) ?? throw new InvalidOperationException("Erro ao criar RDO");
        }
        
        public async Task<RdoDto?> UpdateAsync(int id, UpdateRdoDto updateDto)
        {
            var rdo = await _context.Rdos.FindAsync(id);
            if (rdo == null)
                return null;
            
            rdo.ColaboradorId = updateDto.ColaboradorId;
            rdo.Observacao = updateDto.Observacao;
            rdo.Temperatura = updateDto.Temperatura;
            rdo.CondicoesTempo = updateDto.CondicoesTempo;
            rdo.Status = updateDto.Status;
            rdo.DataAtualizacao = DateTime.Now;
            
            await _context.SaveChangesAsync();
            
            return await GetByIdAsync(id);
        }
        
        public async Task<bool> DeleteAsync(int id)
        {
            var rdo = await _context.Rdos.FindAsync(id);
            if (rdo == null)
                return false;
            
            _context.Rdos.Remove(rdo);
            await _context.SaveChangesAsync();
            
            return true;
        }
        
        public async Task<bool> ExistsAsync(int obraId, DateTime data)
        {
            return await _context.Rdos
                .AnyAsync(r => r.ObraId == obraId && r.Data.Date == data.Date);
        }
    }
}