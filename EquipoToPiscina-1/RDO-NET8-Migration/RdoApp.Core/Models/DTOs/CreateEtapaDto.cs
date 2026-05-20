using System;
using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Create Etapa DTO - For creating new stages
    /// Used when creating new stages in projects
    /// </summary>
    public class CreateEtapaDto
    {
        [Required(ErrorMessage = "Título é obrigatório")]
        [StringLength(200, ErrorMessage = "Título deve ter no máximo 200 caracteres")]
        public string Titulo { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "Descrição deve ter no máximo 500 caracteres")]
        public string Descricao { get; set; } = string.Empty;

        [Required(ErrorMessage = "Obra é obrigatória")]
        public int ObraId { get; set; }

        [Required(ErrorMessage = "Data de início é obrigatória")]
        public DateTime DataInicio { get; set; }

        [Required(ErrorMessage = "Data de previsão de fim é obrigatória")]
        public DateTime DataPrevisaoFim { get; set; }
    }
}