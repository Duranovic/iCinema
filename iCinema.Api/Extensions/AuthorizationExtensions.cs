using Microsoft.AspNetCore.Authorization;

namespace iCinema.Api.Extensions;

/// <summary>
/// Extension methods for configuring authorization policies.
/// </summary>
public static class AuthorizationExtensions
{
    /// <summary>
    /// Adds custom authorization policies to the service collection.
    /// </summary>
    public static IServiceCollection AddApiAuthorizationPolicies(this IServiceCollection services)
    {
        services.AddAuthorization(options =>
        {
            // Admin-only policy
            options.AddPolicy("AdminOnly", policy =>
                policy.RequireRole("Admin"));

            // Admin or Staff policy
            options.AddPolicy("AdminOrStaff", policy =>
                policy.RequireRole("Admin", "Staff"));

            // Authenticated user policy (default)
            options.AddPolicy("Authenticated", policy =>
                policy.RequireAuthenticatedUser());
        });

        return services;
    }
}

