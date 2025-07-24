using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Handlers;

public class GetFilteredGenresHandler(IGenreRepository repository)
    : GetFilteredHandler<GenreDto, GenreCreateDto, GenreUpdateDto, GenreFilter>(repository);