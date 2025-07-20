using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries;

public record GetCitiesByCountryQuery(Guid CountryId) : IRequest<IEnumerable<CityDto>>;