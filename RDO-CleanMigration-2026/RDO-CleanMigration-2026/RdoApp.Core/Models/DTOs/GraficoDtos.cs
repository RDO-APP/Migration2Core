namespace RdoApp.Core.Models.Dtos;

public sealed class GraficoRdoGeradoRow
{
    public string obr_ds_obra { get; set; } = "";
    public int gerado { get; set; }
    public int assinado_contratante { get; set; }
    public int assinado_contratada { get; set; }
    public int? a_gerar { get; set; }
}

public sealed class GraficoRdoAtrasadoRow
{
    public string obr_ds_obra { get; set; } = "";
    public int? dias_atraso { get; set; }
    public int sem_ass_contratante { get; set; }
    public int sem_ass_contratada { get; set; }
}

public sealed class GraficoDiaImprodutivoRow
{
    public string obr_ds_obra { get; set; } = "";
    public int imp_clima { get; set; }
    public int imp_falta_material { get; set; }
    public int imp_paralizacao { get; set; }
    public int imp_acidente { get; set; }
    public int imp_contratante { get; set; }
    public int imp_equipamento { get; set; }
    public int imp_fornecedores { get; set; }
    public int imp_maodeobra { get; set; }
    public int imp_projeto { get; set; }
    public int imp_planejamento { get; set; }
}

public sealed class GraficoTarefaRow
{
    public string obr_ds_obra { get; set; } = "";
    public int atraso_inicio { get; set; }
    public int atraso_fim { get; set; }
    public int pausadas { get; set; }
    public int canceladas { get; set; }
}

public sealed class GraficoStatusTarefaRow
{
    public string obr_ds_obra { get; set; } = "";
    public int planejada { get; set; }
    public int em_execucao { get; set; }
    public int finalizada { get; set; }
    public int pausada { get; set; }
    public int cancelada { get; set; }
}

public sealed class GraficoComentarioRow
{
    public string obr_ds_obra { get; set; } = "";
    public int positivo_contratante { get; set; }
    public int negativo_contratante { get; set; }
    public int positivo_contratada { get; set; }
    public int negativo_contratada { get; set; }
}

public sealed class GraficoResumoDto
{
    public string PeriodoIni { get; set; } = "";
    public string PeriodoFim { get; set; } = "";
    public List<GraficoRdoAtrasadoRow> RdosAtrasados { get; set; } = [];
    public List<GraficoRdoGeradoRow> RdosGerados { get; set; } = [];
    public List<GraficoDiaImprodutivoRow> DiasImprodutivos { get; set; } = [];
    public List<GraficoTarefaRow> Tarefas { get; set; } = [];
    public List<GraficoStatusTarefaRow> StatusTarefas { get; set; } = [];
    public List<GraficoComentarioRow> Comentarios { get; set; } = [];
}

public sealed class DashboardSliceDto
{
    public string Name { get; set; } = "";
    public int Y { get; set; }
}

public sealed class DashboardObraDto
{
    public List<DashboardSliceDto> PizzaColaboradores { get; set; } = [];
    public List<string> BarraCategorias { get; set; } = [];
    public List<int> BarraValores { get; set; } = [];
    public List<DashboardSliceDto> PizzaEfetivo { get; set; } = [];
}
