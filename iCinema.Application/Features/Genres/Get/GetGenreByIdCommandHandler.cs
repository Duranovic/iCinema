
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Get;

public class GetGenreByIdCommandHandler(IGenreRepository repository)
    : GetByIdHandler<GenreDto, GenreCreateDto, GenreUpdateDto>(repository);
