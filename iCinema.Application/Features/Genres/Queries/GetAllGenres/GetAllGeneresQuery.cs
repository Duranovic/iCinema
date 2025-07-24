using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Genres;
using MediatR;

namespace iCinema.Application.Features.Genres.Queries.GetAllGenres;

public record GetAllGeneresQuery : IRequest<IEnumerable<GenreDto>>;