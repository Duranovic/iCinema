using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Update;

public class UpdateGenreCommandHandler(IGenreRepository repository)
    : UpdateHandler<GenreDto, GenreCreateDto, GenreUpdateDto>(repository);