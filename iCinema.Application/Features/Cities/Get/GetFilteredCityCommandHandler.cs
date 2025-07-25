using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Get;

public class GetFilteredCityCommandHandler(ICityRepository repository)
    : GetFilteredHandler<CityDto, CityCreateDto, CityUpdateDto, CityFilter>(repository);