using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries.GetCitiesByCountry;

public record GetCitiesByCountryQuery(Guid CountryId) : IRequest<IEnumerable<CityDto>>;