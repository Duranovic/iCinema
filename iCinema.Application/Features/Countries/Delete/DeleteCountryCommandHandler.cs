
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Delete;

public class DeleteCountryCommandHandler(ICountryRepository repository)
    : DeleteHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);
