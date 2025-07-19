using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Genres.Queries;

public class GetAllGeneresQuery : IRequest<IEnumerable<GenreDto>>;