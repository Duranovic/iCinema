using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetCinemaById;

public record GetCinemaByIdQuery(Guid Id) : IRequest<CinemaDto?>;