using Microsoft.Extensions.DependencyInjection;

namespace iCinema.Application.DependencyInjection;

public static class ApplicationServiceRegistration
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(ApplicationServiceRegistration).Assembly);
        });

        return services;
    }
}