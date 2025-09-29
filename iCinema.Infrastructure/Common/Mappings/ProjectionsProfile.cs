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
            .ForMember(dest => dest.Movie, opt => opt.MapFrom(src => src.Movie))
            .ForMember(dest => dest.CinemaName, opt => opt.MapFrom(src => src.Hall.Cinema.Name))
            .ForMember(dest => dest.HallName, opt => opt.MapFrom(src => src.Hall.Name))
            .ForMember(dest => dest.CinemaId, opt => opt.MapFrom(src => src.Hall.CinemaId));
        CreateMap<ProjectionDto, Projection>();
        CreateMap<ProjectionCreateDto, Projection>();
        CreateMap<ProjectionUpdateDto, Projection>();
    }
}