using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cities.Handlers;

public class GetCityByIdHandler(ICityRepository repository)
    : GetByIdHandler<CityDto, CityCreateDto, CityUpdateDto>(repository);