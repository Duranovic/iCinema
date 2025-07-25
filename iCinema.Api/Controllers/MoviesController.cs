using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[Authorize(Roles = "Admin,Staff")]
[ApiController]
public class MoviesController(IMediator mediator) : BaseController<MovieDto, MovieCreateDto, MovieUpdateDto, MovieFilter>(mediator);