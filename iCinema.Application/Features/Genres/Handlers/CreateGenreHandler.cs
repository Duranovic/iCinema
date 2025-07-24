using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Country;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Genres.Handlers;

public class CreateGenreHandler(IGenreRepository repository) : 
    CreateHandler<GenreDto, GenreCreateDto, GenreUpdateDto>(repository);