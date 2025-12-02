using System.Reflection;
using FluentValidation;
using iCinema.Application.Common.Handlers;
using iCinema.Application.Common.Requests;
using iCinema.Application.Common.Validations.Behaviors;
using iCinema.Application.DTOs.Actor;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.DTOs.City;
using iCinema.Application.DTOs.Country;
using iCinema.Application.DTOs.Director;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.DTOs.Movie;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace iCinema.Application.DependencyInjection;

public static class ApplicationServiceRegistration
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly());
            cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        });
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        // Register generic Create handlers explicitly for types that don't have specific handlers
        services.AddTransient<IRequestHandler<CreateCommand<ActorDto, ActorCreateDto>, ActorDto>, CreateHandler<ActorDto, ActorCreateDto, ActorUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<DirectorDto, DirectorCreateDto>, DirectorDto>, CreateHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<GenreDto, GenreCreateDto>, GenreDto>, CreateHandler<GenreDto, GenreCreateDto, GenreUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<CityDto, CityCreateDto>, CityDto>, CreateHandler<CityDto, CityCreateDto, CityUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<CountryDto, CountryCreateDto>, CountryDto>, CreateHandler<CountryDto, CountryCreateDto, CountryUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<CinemaDto, CinemaCreateDto>, CinemaDto>, CreateHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>>();
        services.AddTransient<IRequestHandler<CreateCommand<HallDto, HallCreateDto>, HallDto>, CreateHandler<HallDto, HallCreateDto, HallUpdateDto>>();
        
        // Register generic Update handlers (Cinema has a specific handler, so it's picked up by RegisterServicesFromAssembly)
        services.AddTransient<IRequestHandler<UpdateCommand<ActorDto, ActorUpdateDto>, ActorDto?>, UpdateHandler<ActorDto, ActorCreateDto, ActorUpdateDto>>();
        services.AddTransient<IRequestHandler<UpdateCommand<DirectorDto, DirectorUpdateDto>, DirectorDto?>, UpdateHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>>();
        services.AddTransient<IRequestHandler<UpdateCommand<GenreDto, GenreUpdateDto>, GenreDto?>, UpdateHandler<GenreDto, GenreCreateDto, GenreUpdateDto>>();
        services.AddTransient<IRequestHandler<UpdateCommand<CityDto, CityUpdateDto>, CityDto?>, UpdateHandler<CityDto, CityCreateDto, CityUpdateDto>>();
        services.AddTransient<IRequestHandler<UpdateCommand<CountryDto, CountryUpdateDto>, CountryDto?>, UpdateHandler<CountryDto, CountryCreateDto, CountryUpdateDto>>();
        // Cinema has UpdateCinemaCommandHandler, so it's registered via RegisterServicesFromAssembly
        services.AddTransient<IRequestHandler<UpdateCommand<HallDto, HallUpdateDto>, HallDto?>, UpdateHandler<HallDto, HallCreateDto, HallUpdateDto>>();
        
        // Register generic Delete handlers
        services.AddTransient<IRequestHandler<DeleteCommand<ActorDto>, bool>, DeleteHandler<ActorDto, ActorCreateDto, ActorUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<DirectorDto>, bool>, DeleteHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<GenreDto>, bool>, DeleteHandler<GenreDto, GenreCreateDto, GenreUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<CityDto>, bool>, DeleteHandler<CityDto, CityCreateDto, CityUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<CountryDto>, bool>, DeleteHandler<CountryDto, CountryCreateDto, CountryUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<CinemaDto>, bool>, DeleteHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>>();
        services.AddTransient<IRequestHandler<DeleteCommand<HallDto>, bool>, DeleteHandler<HallDto, HallCreateDto, HallUpdateDto>>();
        
        // Note: Movie and User have specific handlers, so they are picked up by RegisterServicesFromAssembly
        
        return services;
    }
}
