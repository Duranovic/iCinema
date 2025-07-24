using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Handlers;

public class DeleteMovieHandler(IMovieRepository repository)
    : DeleteHandler<MovieDto, MovieCreateDto, MovieUpdateDto>(repository);