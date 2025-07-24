using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Cinema;
using MediatR;

namespace iCinema.Api.Controllers;

public class CinemasController(IMediator mediator) : 
    BaseController<CinemaDto, CinemaCreateDto, CinemaUpdateDto, CinemaFilter>(mediator);