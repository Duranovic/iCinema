using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Director;
using MediatR;

namespace iCinema.Api.Controllers;

public class DirectorsController(IMediator mediator)
    : BaseController<DirectorDto, DirectorCreateDto, DirectorUpdateDto, DirectorFilter>(mediator);
