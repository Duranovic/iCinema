using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Hall;
using MediatR;

namespace iCinema.Api.Controllers;

public class HallsController(IMediator mediator) : BaseController<HallDto, HallCreateDto, HallUpdateDto, HallFilter>(mediator);