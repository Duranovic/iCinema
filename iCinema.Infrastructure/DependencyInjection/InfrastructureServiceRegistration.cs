using System.Text;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.DTOs.Actor;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.DTOs.City;
using iCinema.Application.DTOs.Country;
using iCinema.Application.DTOs.Director;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Common.Mappings;
using MassTransit;
using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Repositories;
using iCinema.Infrastructure.Services;
using iCinema.Infrastructure.Messaging.Consumers;
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
        
        // Unit of Work
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        
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
        services.AddScoped<ICinemaRepository, CinemaRepository>();
        services.AddScoped<IRoleRepository, RoleRepository>();
        services.AddScoped<IProjectionRepository, ProjectionRepository>();
        services.AddScoped<IHallRepository, HallRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IReservationRepository, ReservationRepository>();
        services.AddScoped<IHomeKpisRepository, HomeKpisRepository>();
        services.AddScoped<IRecommendationRepository, RecommendationRepository>();
        services.AddScoped<IDirectorRepository, DirectorRepository>();
        services.AddScoped<IRatingRepository, RatingRepository>();
        services.AddScoped<ITicketRepository, TicketRepository>();
        services.AddScoped<INotificationsRepository, NotificationsRepository>();
        services.AddScoped<IActorRepository, ActorRepository>();
        
        // Register repositories as IBaseRepository for generic handlers
        services.AddScoped<IBaseRepository<ActorDto, ActorCreateDto, ActorUpdateDto>>(sp => sp.GetRequiredService<IActorRepository>());
        services.AddScoped<IBaseRepository<DirectorDto, DirectorCreateDto, DirectorUpdateDto>>(sp => sp.GetRequiredService<IDirectorRepository>());
        services.AddScoped<IBaseRepository<GenreDto, GenreCreateDto, GenreUpdateDto>>(sp => sp.GetRequiredService<IGenreRepository>());
        services.AddScoped<IBaseRepository<CityDto, CityCreateDto, CityUpdateDto>>(sp => sp.GetRequiredService<ICityRepository>());
        services.AddScoped<IBaseRepository<CountryDto, CountryCreateDto, CountryUpdateDto>>(sp => sp.GetRequiredService<ICountryRepository>());
        services.AddScoped<IBaseRepository<CinemaDto, CinemaCreateDto, CinemaUpdateDto>>(sp => sp.GetRequiredService<ICinemaRepository>());
        services.AddScoped<IBaseRepository<HallDto, HallCreateDto, HallUpdateDto>>(sp => sp.GetRequiredService<IHallRepository>());
        
        // Services
        services.AddScoped<IProjectionRulesService, Services.Rules.ProjectionRulesService>();
        services.AddScoped<ICountryRulesService, Services.Rules.CountryRulesService>();
        services.AddScoped<IGenreRulesService, Services.Rules.GenreRulesService>();
        services.AddScoped<ICityRulesService, Services.Rules.CityRulesService>();
        services.AddScoped<ICinemaRulesService, Services.Rules.CinemaRulesService>();
        services.AddScoped<IMovieRulesService, Services.Rules.MovieRulesService>();
        services.AddScoped<IDirectorRulesService, Services.Rules.DirectorRulesService>();
        services.AddScoped<IReportsService, ReportsService>();
        services.AddSingleton<IQrCodeService, QrCodeService>();
        services.AddSingleton<IFileStorageService, LocalFileStorageService>();
        services.AddSingleton<ImageProcessingService>();
        services.AddHttpContextAccessor();

        // MassTransit + RabbitMQ
        services.AddMassTransit(cfg =>
        {
            cfg.AddConsumer<NotificationsConsumer>();

            cfg.UsingRabbitMq((context, busCfg) =>
            {
                var host = configuration["RabbitMQ:Host"] ?? "amqp://guest:guest@localhost:5672";
                busCfg.Host(new Uri(host));

                busCfg.ReceiveEndpoint("notifications.queue", e =>
                {
                    e.ConfigureConsumer<NotificationsConsumer>(context);
                });
            });
        });

        // Identity Server / JWT
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
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!)),
                NameClaimType = System.Security.Claims.ClaimTypes.NameIdentifier
            };
            
            // Support token in query string for SignalR
            options.Events = new Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerEvents
            {
                OnMessageReceived = context =>
                {
                    var accessToken = context.Request.Query["access_token"];
                    var path = context.HttpContext.Request.Path;
                    if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                    {
                        context.Token = accessToken;
                    }
                    return Task.CompletedTask;
                }
            };
        });

        // All AutoMapper profiles are in the same assembly, so only one registration is needed
        services.AddAutoMapper(typeof(MovieProfile).Assembly);
        
        return services;
    }
}