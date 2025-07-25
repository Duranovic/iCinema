
using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Get;

public class GetFilteredCountriesCommandHandler(ICountryRepository repository)
    : GetFilteredHandler<CountryDto, CountryCreateDto, CountryUpdateDto, CountryFilter>(repository);
