
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Delete;

public class DeleteGenreCommandHandler(IGenreRepository repository)
    : DeleteHandler<GenreDto, GenreCreateDto, GenreUpdateDto>(repository);
