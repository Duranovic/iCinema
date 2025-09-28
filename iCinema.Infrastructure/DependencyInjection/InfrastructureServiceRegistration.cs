using System.Text;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Common.Mappings;
using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Repositories;
using iCinema.Infrastructure.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace iCinema.Infrastructure.DependencyInjection;

public static class InfrastructureServiceRegistration
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<iCinemaDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));
        
        services.AddDbContext<iCinemaIdentityContext>(options => 
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));
        
        services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
            {
                options.Password.RequiredLength = 6;
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireUppercase = false;
            })
            .AddEntityFrameworkStores<iCinemaIdentityContext>()
            .AddDefaultTokenProviders();
        
        // Repositories
        services.AddScoped<IMovieRepository, MovieRepository>();
        services.AddScoped<ICountryRepository, CountryRepository>();
        services.AddScoped<IGenreRepository, GenreRepository>();
        services.AddScoped<ICityRepository, CityRepository>();
        services.AddScoped<IRoleRepository, RoleRepository>();
        services.AddScoped<ICinemaRepository, CinemaRepository>();
        services.AddScoped<IProjectionRepository, ProjectionRepository>();
        services.AddScoped<IHallRepository, HallRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IReservationRepository, ReservationRepository>();
        services.AddScoped<IHomeKpisRepository, HomeKpisRepository>();
        services.AddScoped<IRecommendationRepository, RecommendationRepository>();
        services.AddScoped<ITicketRepository, TicketRepository>();
        
        // Services
        services.AddScoped<IProjectionRulesService, ProjectionRulesService>();
        services.AddScoped<ICountryRulesService, CountryRulesService>();
        services.AddScoped<IGenreRulesService, GenreRulesService>();
        services.AddScoped<ICityRulesService, CityRulesService>();
        services.AddScoped<ICinemaRulesService, CinemaRulesService>();
        services.AddScoped<IReportsService, ReportsService>();
        services.AddSingleton<IQrCodeService, QrCodeService>();
        
        // Identity Server
        services.AddScoped<JwtTokenService>();
        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = "Bearer";
            options.DefaultChallengeScheme = "Bearer";
        })
        .AddJwtBearer("Bearer", options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidIssuer = configuration["Jwt:Issuer"],
                ValidAudience = configuration["Jwt:Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!))
            };
        });
            
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