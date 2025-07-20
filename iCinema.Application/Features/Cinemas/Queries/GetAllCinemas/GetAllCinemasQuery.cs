using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetAllCinemas;

public record GetAllCinemasQuery : IRequest<IEnumerable<CinemaDto>>;