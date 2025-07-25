using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Create;

public class CreateMovieCommandHandler(IMovieRepository repository)
    : CreateHandler<MovieDto, MovieCreateDto, MovieUpdateDto>(repository);