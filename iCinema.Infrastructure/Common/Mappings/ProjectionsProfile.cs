using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class ProjectionsProfile : Profile
{
    public ProjectionsProfile()
    {
        CreateMap<Projection, ProjectionDto>()
            .ForMember(dest => dest.MovieTitle, opt => opt.MapFrom(src => src.Movie.Title))
            .ForMember(dest => dest.CinemaName, opt => opt.MapFrom(src => src.Hall.Cinema.Name));
        
        CreateMap<ProjectionDto, Projection>();
    }
}