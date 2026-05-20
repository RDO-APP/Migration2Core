using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Services.Interfaces;
using System.Globalization;

namespace RdoApp.Core.Services.Implementations
{
    public class LaudoService : ILaudoService
    {
        private readonly RdoContext _context;
        private static readonly CultureInfo CultureInfo = new("pt-BR");

        public LaudoService(RdoContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<LaudoDto>> GetAllAsync()
        {
            var laudos = await _context.Laudos
                .Include(l => l.Status)
                .Include(l => l.Obra)
                .Include(l => l.Colaborador)
                .OrderByDescending(l => l.Id)
                .ToListAsync();

            return laudos.Select(MapToDto);
        }

        public async Task<LaudoDto?> GetByIdAsync(int id)
        {
            var laudo = await _context.Laudos
                .Include(l => l.Status)
                .Include(l => l.Obra)
                .Include(l => l.Colaborador)
                .FirstOrDefaultAsync(l => l.Id == id);

            return laudo != null ? MapToDto(laudo) : null;
        }

        public async Task<IEnumerable<LaudoDto>> GetByObraIdAsync(int obraId)
        {
            var laudos = await _context.Laudos
                .Include(l => l.Status)
                .Include(l => l.Obra)
                .Include(l => l.Colaborador)
                .Where(l => l.ObraId == obraId)
                .OrderByDescending(l => l.DataLaudo)
                .ToListAsync();

            return laudos.Select(MapToDto);
        }

        public async Task<IEnumerable<LaudoDto>> GetByStatusIdAsync(int statusId)
        {
            var laudos = await _context.Laudos
                .Include(l => l.Status)
                .Include(l => l.Obra)
                .Include(l => l.Colaborador)
                .Where(l => l.StatusId == statusId)
                .OrderByDescending(l => l.DataLaudo)
                .ToListAsync();

            return laudos.Select(MapToDto);
        }

        public async Task<IEnumerable<LaudoDto>> GetByDateRangeAsync(DateTime dataInicial, DateTime dataFinal)
        {
            var laudos = await _context.Laudos
                .Include(l => l.Status)
                .Include(l => l.Obra)
                .Include(l => l.Colaborador)
                .Where(l => l.DataLaudo >= dataInicial && l.DataLaudo <= dataFinal)
                .OrderByDescending(l => l.DataLaudo)
                .ToListAsync();

            return laudos.Select(MapToDto);
        }

        public async Task<LaudoDto> CreateAsync(CreateLaudoDto createDto)
        {
            // Validate obra exists
            var obra = await _context.Obras.FindAsync(createDto.ObraId);
            if (obra == null)
                throw new ArgumentException("Obra não encontrada");

            // Validate date is not before obra start date
            if (createDto.DataLaudo < obra.DataInicio)
                throw new ArgumentException("Não é possível gerar um laudo anterior à data inicial da obra");

            // Validate date is not after obra end date (if exists)
            if (obra.DataFim.HasValue && createDto.DataLaudo > obra.DataFim.Value)
                throw new ArgumentException("Não é possível gerar um laudo posterior à data final da obra");

            // Check if laudo already exists for this date and obra
            var existingLaudo = await _context.Laudos
                .FirstOrDefaultAsync(l => l.ObraId == createDto.ObraId && l.DataLaudo.Date == createDto.DataLaudo.Date);

            if (existingLaudo != null)
                throw new ArgumentException("Já existe um laudo para esta data e obra");

            var laudo = new Laudo
            {
                StatusId = 1, // Default status - "Gerado"
                ObraId = createDto.ObraId,
                DataLaudo = createDto.DataLaudo,
                ColaboradorId = createDto.ColaboradorId,
                DataGeracao = DateTime.Now,
                ComentarioGeracao = createDto.ComentarioGeracao,
                TipoComentarioGeracao = createDto.TipoComentarioGeracao,
                NivelCloro = createDto.NivelCloro,
                Ph = createDto.Ph,
                Alcalinidade = createDto.Alcalinidade,
                Limpidez = createDto.Limpidez,
                Superficie = createDto.Superficie,
                Fundo = createDto.Fundo,
                NivelCloro2 = createDto.NivelCloro2,
                NivelBacterias = createDto.NivelBacterias,
                NivelProliferacao = createDto.NivelProliferacao
            };

            _context.Laudos.Add(laudo);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(laudo.Id) ?? throw new InvalidOperationException("Erro ao criar laudo");
        }

        public async Task<LaudoDto?> UpdateAsync(int id, UpdateLaudoDto updateDto)
        {
            var laudo = await _context.Laudos.FindAsync(id);
            if (laudo == null)
                return null;

            // Update fields
            if (updateDto.ComentarioAssinatura != null)
                laudo.ComentarioAssinatura = updateDto.ComentarioAssinatura;
            
            if (updateDto.TipoComentarioAssinatura != null)
                laudo.TipoComentarioAssinatura = updateDto.TipoComentarioAssinatura;
            
            if (updateDto.ComentarioGeracao != null)
                laudo.ComentarioGeracao = updateDto.ComentarioGeracao;
            
            if (updateDto.TipoComentarioGeracao != null)
                laudo.TipoComentarioGeracao = updateDto.TipoComentarioGeracao;

            // Update water quality fields
            if (updateDto.NivelCloro.HasValue)
                laudo.NivelCloro = updateDto.NivelCloro;
            
            if (updateDto.Ph.HasValue)
                laudo.Ph = updateDto.Ph;
            
            if (updateDto.Alcalinidade.HasValue)
                laudo.Alcalinidade = updateDto.Alcalinidade;
            
            if (updateDto.Limpidez.HasValue)
                laudo.Limpidez = updateDto.Limpidez;
            
            if (updateDto.Superficie.HasValue)
                laudo.Superficie = updateDto.Superficie;
            
            if (updateDto.Fundo.HasValue)
                laudo.Fundo = updateDto.Fundo;
            
            if (updateDto.NivelCloro2.HasValue)
                laudo.NivelCloro2 = updateDto.NivelCloro2;
            
            if (updateDto.NivelBacterias.HasValue)
                laudo.NivelBacterias = updateDto.NivelBacterias;
            
            if (updateDto.NivelProliferacao.HasValue)
                laudo.NivelProliferacao = updateDto.NivelProliferacao;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var laudo = await _context.Laudos.FindAsync(id);
            if (laudo == null)
                return false;

            _context.Laudos.Remove(laudo);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ExistsAsync(int obraId, DateTime dataLaudo)
        {
            return await _context.Laudos
                .AnyAsync(l => l.ObraId == obraId && l.DataLaudo.Date == dataLaudo.Date);
        }

        private static LaudoDto MapToDto(Laudo laudo)
        {
            return new LaudoDto
            {
                Id = laudo.Id,
                StatusId = laudo.StatusId,
                StatusDescricao = laudo.Status?.Descricao,
                ObraId = laudo.ObraId,
                ObraDescricao = laudo.Obra?.Descricao,
                DataLaudo = laudo.DataLaudo,
                ComentarioAssinatura = laudo.ComentarioAssinatura,
                ColaboradorId = laudo.ColaboradorId,
                ColaboradorNome = laudo.Colaborador?.Nome,
                DataGeracao = laudo.DataGeracao,
                TipoComentarioAssinatura = laudo.TipoComentarioAssinatura,
                ComentarioGeracao = laudo.ComentarioGeracao,
                TipoComentarioGeracao = laudo.TipoComentarioGeracao,
                NivelCloro = laudo.NivelCloro,
                Ph = laudo.Ph,
                Alcalinidade = laudo.Alcalinidade,
                Limpidez = laudo.Limpidez,
                Superficie = laudo.Superficie,
                Fundo = laudo.Fundo,
                NivelCloro2 = laudo.NivelCloro2,
                NivelBacterias = laudo.NivelBacterias,
                NivelProliferacao = laudo.NivelProliferacao,
                DiaDaSemana = CultureInfo.DateTimeFormat.DayNames[(int)laudo.DataLaudo.DayOfWeek]
            };
        }
    }
}