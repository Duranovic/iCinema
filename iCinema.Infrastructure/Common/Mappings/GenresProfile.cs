using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class GenresProfile : Profile
{
    public GenresProfile()
    {
        CreateMap<Genre, GenreDto>();
        CreateMap<GenreDto, Genre>();
    }
}