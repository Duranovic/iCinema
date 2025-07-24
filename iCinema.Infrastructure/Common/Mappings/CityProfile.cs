using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class CityProfile : Profile
{
    public CityProfile()
    {
        CreateMap<City, CityDto>();
        CreateMap<CityDto, City>();
        CreateMap<CityCreateDto, City>();
        CreateMap<CityUpdateDto, City>();
    }
}