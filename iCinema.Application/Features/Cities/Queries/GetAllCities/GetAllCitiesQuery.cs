using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries.GetAllCities;

public record GetAllCitiesQuery : IRequest<IEnumerable<CityDto>>;