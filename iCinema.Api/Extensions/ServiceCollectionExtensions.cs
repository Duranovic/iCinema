using Microsoft.Extensions.DependencyInjection;

namespace iCinema.Api.Extensions;

/// <summary>
/// Extension methods for configuring services in the API layer.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds CORS configuration based on environment.
    /// </summary>
    public static IServiceCollection AddApiCors(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddCors(options =>
        {
            var enableDevCors = configuration.GetValue<bool>("Cors:EnableDevCors", true);
            
            if (enableDevCors)
            {
                // Development CORS - allows any origin
                options.AddPolicy("DevCors", policy =>
                    policy
                        .AllowAnyOrigin()
                        .AllowAnyHeader()
                        .AllowAnyMethod());
            }
            else
            {
                // Production CORS - restricted origins
                var allowedOrigins = configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() 
                    ?? Array.Empty<string>();
                
                options.AddPolicy("ProductionCors", policy =>
                    policy
                        .WithOrigins(allowedOrigins)
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials());
            }
        });

        return services;
    }
}

