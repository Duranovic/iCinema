using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Countries.Queries;

public class GetAllCountriesQuery : IRequest<IEnumerable<CountryDto>>;