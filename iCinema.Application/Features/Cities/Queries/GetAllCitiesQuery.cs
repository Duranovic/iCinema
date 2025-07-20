using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries;

public record GetAllCitiesQuery : IRequest<IEnumerable<CityDto>>;