using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using MediatR;

namespace iCinema.Api.Controllers;

public class MoviesController(IMediator mediator) : BaseController<MovieDto, MovieCreateDto, MovieUpdateDto, MovieFilter>(mediator);