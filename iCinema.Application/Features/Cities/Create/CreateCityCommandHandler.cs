using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Create;

public class CreateCityCommandHandler(ICityRepository repository)
    : CreateHandler<CityDto, CityCreateDto, CityUpdateDto>(repository);