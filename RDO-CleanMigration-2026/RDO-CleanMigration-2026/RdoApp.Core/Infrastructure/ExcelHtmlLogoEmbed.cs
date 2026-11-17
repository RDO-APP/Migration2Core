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
    /// <summary>Célula de logo compatível com Excel HTML-.xls (sem &lt;img&gt; / data-URI).</summary>
    public static string LogoCellHtml(byte[]? logoBytes, int widthPx = 100, int heightPx = 60)
    {
        // logoBytes reservado para futuro ClosedXML — Excel HTML ignora data: e muitos CSS de div.
        _ = logoBytes;
        var w = Math.Max(48, widthPx);
        var h = Math.Max(48, heightPx);
        // bgcolor em <td> (Excel honra); div+background costuma virar célula branca vazia.
        return $"<table width=\"{w}\" height=\"{h}\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\">"
            + $"<tr><td width=\"{w}\" height=\"{h}\" bgcolor=\"#28496f\" align=\"center\" valign=\"middle\""
            + " style=\"color:#ffffff;font-family:Arial,sans-serif;font-size:18pt;font-weight:bold;\">rdo</td></tr>"
            + "</table>";
    }

    public static byte[] Pack(string htmlDocument, byte[]? logoBytes)
    {
        _ = logoBytes;
        return Encoding.UTF8.GetPreamble().Concat(Encoding.UTF8.GetBytes(htmlDocument)).ToArray();
    }
}
