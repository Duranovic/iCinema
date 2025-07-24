using AutoMapper;
using iCinema.Application.DTOs.Country;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class CountryProfile : Profile
{
    public CountryProfile()
    {
        CreateMap<Country, CountryDto>();
        CreateMap<CountryDto, Country>();
        CreateMap<CountryCreateDto, Country>();
        CreateMap<CountryUpdateDto, Country>();
    }
}