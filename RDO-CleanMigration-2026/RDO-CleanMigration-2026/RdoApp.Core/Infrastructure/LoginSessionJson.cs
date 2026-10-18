using System.Text.Json;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Infrastructure;

public static class LoginSessionJson
{
    private static readonly JsonSerializerOptions Options = new()
    {
        PropertyNameCaseInsensitive = true,
        WriteIndented = false,
    };

    public static LoginViewModel? TryDeserialize(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return null;
        }

        try
        {
            return JsonSerializer.Deserialize<LoginViewModel>(json, Options);
        }
        catch (JsonException)
        {
            return null;
        }
    }

    public static string Serialize(LoginViewModel model) =>
        JsonSerializer.Serialize(model, Options);
}
