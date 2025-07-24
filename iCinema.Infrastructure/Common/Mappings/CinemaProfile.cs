using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Cinema;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class CinemaProfile : Profile
{
    public CinemaProfile()
    {
        CreateMap<Cinema, CinemaDto>()
            .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City.Name))
            .ForMember(dest => dest.CountryName, opt => opt.MapFrom(src => src.City.Country.Name));
        CreateMap<CinemaDto, Cinema>();
        CreateMap<CinemaCreateDto, Cinema>();
        CreateMap<CinemaUpdateDto, Cinema>();
    }
}