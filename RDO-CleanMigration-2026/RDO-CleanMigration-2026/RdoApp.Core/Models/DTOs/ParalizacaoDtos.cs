namespace RdoApp.Core.Models.Dtos;

public class ParalizacaoIndexPermissionsDto
{
    public bool ShowEditar { get; set; }
    public bool ShowDeletar { get; set; }
    public bool ShowNovo { get; set; }
}

public class ParalizacaoIndexBootstrapDto
{
    public string ObraNomeSessao { get; set; } = "";
    public ParalizacaoIndexPermissionsDto Permissions { get; set; } = new();
}

public class ParalizacaoIndexFilterDto
{
    public string? Descricao { get; set; }
}

public class ParalizacaoIndexItemDto
{
    public string Codigo { get; set; } = "";
    public string Descricao { get; set; } = "";
    public bool Editavel { get; set; }
    public bool Excluivel { get; set; }
}

public class ParalizacaoIndexListResponseDto
{
    public string ObraNomeSessao { get; set; } = "";
    public List<ParalizacaoIndexItemDto> Items { get; set; } = [];
}

public class ParalizacaoIndexActionResultDto
{
    public bool Ok { get; set; }
    public string? ErrorMessage { get; set; }
}

public class ParalizacaoCadastroFormDto
{
    public string Codigo { get; set; } = "";
    public string Descricao { get; set; } = "";
    public bool Update { get; set; }
    public bool PodeSalvar { get; set; }
    public string ObraNomeSessao { get; set; } = "";
}

public class ParalizacaoCadastroSaveRequestDto
{
    public string Codigo { get; set; } = "";
    public string Descricao { get; set; } = "";
    public bool Update { get; set; }
}

public class ParalizacaoCadastroSaveResultDto
{
    public bool Ok { get; set; }
    public string? ErrorMessage { get; set; }
    public string? Codigo { get; set; }
}
