using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Handlers;

public class GetFilteredCitiesHandler(ICityRepository repository)
    : GetFilteredHandler<CityDto, CityCreateDto, CityUpdateDto, CityFilter>(repository);