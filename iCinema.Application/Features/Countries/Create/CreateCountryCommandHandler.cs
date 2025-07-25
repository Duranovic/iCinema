
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Create;

public class CreateCountryCommandHandler(ICountryRepository repository) 
    : CreateHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);
