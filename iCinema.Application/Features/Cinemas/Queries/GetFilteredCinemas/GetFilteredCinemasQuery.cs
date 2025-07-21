using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetFilteredCinemas;

public class GetFilteredCinemasQuery : IRequest<IEnumerable<CinemaDto>>
{
    public CinemaFilter Filter { get; init; } = new();
}