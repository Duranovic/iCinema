using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Movies.Queries;

public class GetAllMoviesQuery : IRequest<IQueryable<MovieDto>>;