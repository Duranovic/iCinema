using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class CityProfile : Profile
{
    public CityProfile()
    {
        CreateMap<City, CityDto>();
        CreateMap<CityDto, City>();
    }
}