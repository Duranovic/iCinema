
using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Get;

public class GetFilteredGenresCommandHandler(IGenreRepository repository)
    : GetFilteredHandler<GenreDto, GenreCreateDto, GenreUpdateDto, GenreFilter>(repository);
