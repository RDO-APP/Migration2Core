namespace RdoApp.Core.Infrastructure;

/// <summary>
/// Esquemas aceitos pelas rotas legadas do Apontador (api/obra, api/etapa, api/tarefa, api/Usuario).
/// Bearer = JWT (homolog, cenario B). Cookies = sessao do api/login/LoginUser (producao, cenario A).
/// </summary>
public static class MobileAuthSchemes
{
    public const string BearerOrCookie = "Bearer,Cookies";
}
