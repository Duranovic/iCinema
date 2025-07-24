using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Handlers;

public class DeleteCountryHandler(ICountryRepository repository)
    : DeleteHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);