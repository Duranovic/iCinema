using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Movie;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class MovieProfile : Profile
{
    public MovieProfile()
    {
        CreateMap<Movie, MovieDto>()
            .ForMember(dest => dest.Duration, opt => opt.MapFrom(src => src.DurationMin))
            .ForMember(dest => dest.Genres, opt => opt.MapFrom(src => src.MovieGenres.Select(mg => mg.Genre.Name)))
            .ForMember(dest => dest.DirectorId, opt => opt.MapFrom(src => src.DirectorId))
            .ForMember(dest => dest.DirectorName, opt => opt.MapFrom(src => src.Director != null ? src.Director.FullName : null));
        CreateMap<MovieDto, Movie>()
            .ForMember(dest => dest.DurationMin, opt => opt.MapFrom(src => src.Duration));
        CreateMap<MovieCreateDto, Movie>()
            .ForMember(dest => dest.DurationMin, opt => opt.MapFrom(src => src.Duration))
            .ForMember(dest => dest.MovieGenres, opt => opt.Ignore()); // handled in repository
        CreateMap<MovieUpdateDto, Movie>()
            .ForMember(dest => dest.DurationMin, opt => opt.MapFrom(src => src.Duration))
            .ForMember(dest => dest.MovieGenres, opt => opt.Ignore());
    }
}