using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Delete;

public class DeleteCityHandlerCommand(ICityRepository repository)
    : DeleteHandler<CityDto, CityCreateDto, CityUpdateDto>(repository);