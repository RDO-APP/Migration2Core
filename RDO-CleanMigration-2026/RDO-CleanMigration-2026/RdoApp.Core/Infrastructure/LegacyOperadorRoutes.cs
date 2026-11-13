namespace RdoApp.Core.Infrastructure;

/// <summary>Mapa Angular hash → URL Core homolog (menu BFF + navegação operador).</summary>
public static class LegacyOperadorRoutes
{
    public static string MapHref(string? caminho)
    {
        if (string.IsNullOrWhiteSpace(caminho))
        {
            return "#";
        }

        var path = caminho.Trim();
        if (path.StartsWith("#/", StringComparison.Ordinal))
        {
            path = path[1..];
        }

        path = path.ToLowerInvariant();
        return path switch
        {
            "/chart" or "/chart/index" => "/Chart/Index",
            "/chart/rdos" or "/chart/atrasado" or "/chart/diaimprodutivo" or "/chart/tarefa" or "/chart/comentario" => path,
            "/obra/cadastro" or "/obra/cadastro/index" => "/Obra/Cadastro",
            "/obra/escolher" => "/Obra/Escolher",
            "/obra/index" => "/Obra/Index",
            "/dashboard/index" => "/Dashboard/Index",
            "/tarefa/cards" or "/tarefa/cards/index" => "/Tarefa/Cards",
            "/tarefa/index" => "/Tarefa/Index",
            "/tarefa/cadastro" => "/Tarefa/Cadastro",
            "/rdo/index" or "/rdo/listagem" => "/Rdo/Index",
            "/rdo/cadastro" => "/Rdo/Cadastro",
            "/efetivo/index" or "/efetivo" => "/Efetivo/Index",
            "/tarefa/paralizacoes/index" => "/tarefa/paralizacoes/index",
            "/tarefa/paralizacoes/cadastro" => "/tarefa/paralizacoes/cadastro",
            "/colaborador/index" => "/colaborador/index",
            "/colaborador/cadastro" => "/colaborador/cadastro",
            "/colaborador/alterarsenha" => "/Account/ChangePassword",
            "/equipamento/index" or "/equipamentos/index" => "/equipamento/index",
            "/equipamentos/cadastro" or "/equipamento/cadastro" => "/equipamentos/cadastro",
            "/empresa/index" => "/empresa/index",
            "/empresa/cadastro" => "/empresa/cadastro",
            "/etapa/index" => "/Etapa/Index",
            "/etapa/cadastro" => "/Etapa/Cadastro",
            "/grupo/index" => "/grupo/index",
            "/grupo/cadastro" => "/grupo/cadastro",
            "/menu/index" => "/menu/index",
            "/menu/cadastro" => "/menu/cadastro",
            "/pagina/index" => "/Tarefa/Cards",
            "/pagina/cadastro" => "/pagina/cadastro",
            "/historicoacesso/index" => "/historicoacesso/index",
            "/relatorioprodutividade/index" => "/relatorioprodutividade/index",
            "/relatorioefetivodiario/index" => "/relatorioefetivodiario/index",
            "/relatoriomedicao" or "/relatoriomedicao/index" => "/relatoriomedicao/index",
            "/obra/lista" => "/obra/lista",
            "/convidada" => "/convidada",
            _ when path.StartsWith('/') => path,
            _ => "#",
        };
    }
}
