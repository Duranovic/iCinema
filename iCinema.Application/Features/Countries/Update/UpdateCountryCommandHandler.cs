
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Countries.Update;

public class UpdateCountryCommandHandler(ICountryRepository repository)
    : UpdateHandler<CountryDto, CountryCreateDto, CountryUpdateDto>(repository);
