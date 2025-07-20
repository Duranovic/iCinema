using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Countries.Queries.GetAllCountries;

public record GetAllCountriesQuery : IRequest<IEnumerable<CountryDto>>;