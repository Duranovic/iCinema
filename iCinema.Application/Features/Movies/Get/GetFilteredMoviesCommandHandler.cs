using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Get;

public class GetFilteredMoviesCommandHandler(IMovieRepository repository)
    : GetFilteredHandler<MovieDto, MovieCreateDto, MovieUpdateDto, MovieFilter>(repository);