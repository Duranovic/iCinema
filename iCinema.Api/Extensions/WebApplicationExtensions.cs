using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Seed;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.FileProviders;

namespace iCinema.Api.Extensions;

/// <summary>
/// Extension methods for configuring the WebApplication pipeline.
/// </summary>
public static class WebApplicationExtensions
{
    /// <summary>
    /// Seeds the database with initial data.
    /// </summary>
    public static async Task SeedDatabaseAsync(this WebApplication app)
    {
        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<iCinemaDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<ApplicationRole>>();
        
        await DatabaseSeed.SeedAsync(context, userManager, roleManager);
    }

    /// <summary>
    /// Configures static file serving for uploaded media.
    /// </summary>
    public static WebApplication ConfigureStaticFiles(this WebApplication app, IConfiguration configuration)
    {
        var rootPath = configuration["FileStorage:RootPath"] ?? "uploads";
        var baseUrlPath = configuration["FileStorage:BaseUrlPath"] ?? "/media";
        
        if (!Path.IsPathRooted(rootPath))
        {
            rootPath = Path.Combine(Directory.GetCurrentDirectory(), rootPath);
        }
        
        Directory.CreateDirectory(rootPath);
        
        app.UseStaticFiles(new StaticFileOptions
        {
            FileProvider = new PhysicalFileProvider(rootPath),
            RequestPath = baseUrlPath
        });

        return app;
    }

    /// <summary>
    /// Configures Swagger/OpenAPI for development environment.
    /// </summary>
    public static WebApplication ConfigureSwagger(this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        return app;
    }

    /// <summary>
    /// Configures CORS based on environment settings.
    /// </summary>
    public static WebApplication UseApiCors(this WebApplication app, IConfiguration configuration)
    {
        var enableDevCors = configuration.GetValue<bool>("Cors:EnableDevCors", true);
        var policyName = enableDevCors ? "DevCors" : "ProductionCors";
        
        app.UseCors(policyName);

        return app;
    }
}

