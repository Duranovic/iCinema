using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Movies.Queries.GetAllMovies;

public record GetAllMoviesQuery : IRequest<IQueryable<MovieDto>>;