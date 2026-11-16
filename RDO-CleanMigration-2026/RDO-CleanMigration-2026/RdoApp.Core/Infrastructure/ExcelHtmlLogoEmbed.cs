using System.Text;

namespace RdoApp.Core.Infrastructure;

/// <summary>
/// Excel desktop <b>não</b> renderiza <c>data:</c> URI em HTML salvo como .xls
/// (ícone quebrado / X vermelho). MHTML-<c>cid:</c> gera aviso de formato no Excel 365.
/// Solução estável sem ClosedXML: célula marca "rdo" (navy) no Excel; PDF continua com bitmap.
/// Bitmap embutido no .xls = backlog ClosedXML (<c>M7-REL-*-LAYOUT</c>).
/// </summary>
public static class ExcelHtmlLogoEmbed
{
    /// <summary>Célula de logo compatível com Excel HTML-.xls (sem &lt;img&gt;).</summary>
    public static string LogoCellHtml(byte[]? logoBytes, int widthPx = 100, int heightPx = 60)
    {
        // logoBytes reservado para futuro ClosedXML — hoje HTML não embute bitmap.
        _ = logoBytes;
        var w = Math.Max(48, widthPx);
        var h = Math.Max(48, heightPx);
        return $"<div style=\"width:{w}px;height:{h}px;background:#28496f;color:#fff;"
            + "font-family:Arial,Helvetica,sans-serif;font-size:20pt;font-weight:bold;"
            + $"line-height:{h}px;text-align:center;margin:4px auto;border-radius:6px;\">rdo</div>";
    }

    public static byte[] Pack(string htmlDocument, byte[]? logoBytes)
    {
        _ = logoBytes;
        return Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(htmlDocument)).ToArray();
    }
}
