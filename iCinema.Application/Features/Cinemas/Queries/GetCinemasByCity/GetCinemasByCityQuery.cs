using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetCinemasByCity;

public record GetCinemasByCityQuery(Guid CityId) : IRequest<IEnumerable<CinemaDto>>;