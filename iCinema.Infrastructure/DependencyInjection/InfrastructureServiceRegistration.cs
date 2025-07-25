using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Common.Mappings;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Repositories;
using iCinema.Infrastructure.Services;
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
        services.AddScoped<IGenreRepository, GenreRepository>();
        services.AddScoped<ICityRepository, CityRepository>();
        services.AddScoped<IRoleRepository, RoleRepository>();
        services.AddScoped<ICinemaRepository, CinemaRepository>();
        services.AddScoped<IProjectionRepository, ProjectionRepository>();
        services.AddScoped<IHallRepository, HallRepository>();
        
        // Services
        services.AddScoped<IProjectionRulesService, ProjectionRulesService>();
        services.AddScoped<ICountryRulesService, CountryRulesService>();
        services.AddScoped<IGenreRulesService, GenreRulesService>();
        services.AddScoped<ICityRulesService, CityRulesService>();
        services.AddScoped<ICinemaRulesService, CinemaRulesService>();
        
        // Automapper Profiles
        services.AddAutoMapper(typeof(MovieProfile).Assembly);
        services.AddAutoMapper(typeof(CountryProfile).Assembly);
        services.AddAutoMapper(typeof(GenresProfile).Assembly);
        services.AddAutoMapper(typeof(CityProfile).Assembly);
        services.AddAutoMapper(typeof(RoleProfile).Assembly);
        services.AddAutoMapper(typeof(CinemaProfile).Assembly);
        services.AddAutoMapper(typeof(ProjectionsProfile).Assembly);
        services.AddAutoMapper(typeof(HallProfile).Assembly);
        
        return services;
    }
}