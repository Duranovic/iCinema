using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Get;

public class GetMovieByIdCommandHandler(IMovieRepository repository)
    : GetByIdHandler<MovieDto, MovieCreateDto, MovieUpdateDto>(repository);