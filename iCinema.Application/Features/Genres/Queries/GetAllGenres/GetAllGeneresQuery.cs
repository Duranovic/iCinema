using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Genres.Queries.GetAllGenres;

public record GetAllGeneresQuery : IRequest<IEnumerable<GenreDto>>;