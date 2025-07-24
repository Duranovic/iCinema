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
            .ForMember(dest => dest.Genres, opt => opt.MapFrom(src => src.MovieGenres.Select(mg => mg.Genre.Name)));
        CreateMap<MovieDto, Movie>();
        CreateMap<MovieCreateDto, Movie>()
            .ForMember(dest => dest.MovieGenres, opt => opt.Ignore()); // handled in repository
        CreateMap<MovieUpdateDto, Movie>()
            .ForMember(dest => dest.MovieGenres, opt => opt.Ignore());
    }
}