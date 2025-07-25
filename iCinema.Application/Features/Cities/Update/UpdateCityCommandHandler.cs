using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Update;

public class UpdateCityCommandHandler(ICityRepository repository)
    : UpdateHandler<CityDto, CityCreateDto, CityUpdateDto>(repository);