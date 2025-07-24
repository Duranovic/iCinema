using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Handlers;

public class UpdateMovieHandler(IMovieRepository repository)
    : UpdateHandler<MovieDto, MovieCreateDto, MovieUpdateDto>(repository);