using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Common.Mappings;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace iCinema.Infrastructure.DependencyInjection;

public static class InfrastructureServiceRegistration
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<iCinemaDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));
        
        // Repositories
        services.AddScoped<IMovieRepository, MovieRepository>();
        services.AddScoped<ICountryRepository, CountryRepository>();
        services.AddScoped<IGenresRepository, GenresRepository>();
        services.AddScoped<ICityRepository, CityRepository>();
        
        // Automapper Profiles
        services.AddAutoMapper(typeof(MovieProfile).Assembly);
        services.AddAutoMapper(typeof(CountryProfile).Assembly);
        services.AddAutoMapper(typeof(GenresProfile).Assembly);
        services.AddAutoMapper(typeof(CityProfile).Assembly);
        
        return services;
    }
}