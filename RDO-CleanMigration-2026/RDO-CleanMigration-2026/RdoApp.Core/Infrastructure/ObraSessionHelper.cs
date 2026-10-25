namespace RdoApp.Core.Infrastructure;

public static class ObraSessionHelper
{
    public static bool HasObraSelected(HttpContext context)
    {
        return context.Session.GetInt32(SessionKeys.ObraId) is > 0;
    }

    public static int? GetObraId(HttpContext context) => context.Session.GetInt32(SessionKeys.ObraId);

    public static string? GetObraNome(HttpContext context) => context.Session.GetString(SessionKeys.ObraNome);

    public static string? GetObraCidadeEstado(HttpContext context) =>
        context.Session.GetString(SessionKeys.ObraCidadeEstado);
}
