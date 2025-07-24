using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Handlers;

public class GetCountryByIdHandler(ICountryRepository repository)
    : GetByIdHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);