using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICityRepository : IBaseRepository<CityDto, CityCreateDto, CityUpdateDto>;