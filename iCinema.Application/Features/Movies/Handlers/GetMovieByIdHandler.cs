using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Handlers;

public class GetMovieByIdHandler(IMovieRepository repository)
    : GetByIdHandler<MovieDto, MovieCreateDto, MovieUpdateDto>(repository);