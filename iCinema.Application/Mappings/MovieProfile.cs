using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Domain.Entities;

namespace iCinema.Application.Mappings;

public class MovieProfile : Profile
{
    public MovieProfile()
    {
        CreateMap<Movie, MovieDto>();
        CreateMap<MovieDto, Movie>();
    }
}