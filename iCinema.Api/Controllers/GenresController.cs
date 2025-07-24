using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Genres;
using MediatR;

namespace iCinema.Api.Controllers;

public class GenresController (IMediator mediator) : 
    BaseController<GenreDto, GenreCreateDto, GenreUpdateDto, GenreFilter>(mediator);