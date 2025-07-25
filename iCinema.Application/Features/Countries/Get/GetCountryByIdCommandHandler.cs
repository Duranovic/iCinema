
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Get;

public class GetCountryByIdCommandHandler(ICountryRepository repository)
    : GetByIdHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);
