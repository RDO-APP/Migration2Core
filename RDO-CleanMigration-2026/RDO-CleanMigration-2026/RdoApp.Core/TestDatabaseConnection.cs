using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;

namespace RdoApp.Core;

/// <summary>
/// Simple test to verify database connection
/// Run this to test Phase 1.2.3
/// </summary>
public static class TestDatabaseConnection
{
    public static async Task<bool> TestConnectionAsync(RdoDbContext context, ILogger logger)
    {
        try
        {
            logger.LogInformation("Testing database connection...");
            
            // Try to connect and execute a simple query
            var canConnect = await context.Database.CanConnectAsync();
            
            if (canConnect)
            {
                logger.LogInformation("✅ Database connection successful!");
                
                // Test querying UF table
                var ufCount = await context.UFs.CountAsync();
                logger.LogInformation("Found {Count} states (UF) in database", ufCount);
                
                // Test querying Municipio table
                var municipioCount = await context.Municipios.CountAsync();
                logger.LogInformation("Found {Count} cities (Municipio) in database", municipioCount);
                
                return true;
            }
            else
            {
                logger.LogError("❌ Cannot connect to database");
                return false;
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "❌ Database connection test failed: {Message}", ex.Message);
            return false;
        }
    }
}
