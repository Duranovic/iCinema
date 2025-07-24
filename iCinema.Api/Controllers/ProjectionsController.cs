using iCinema.Application.DTOs;
using iCinema.Application.Common.Filters;
using MediatR;

namespace iCinema.Api.Controllers
{
    public class ProjectionsController(IMediator mediator)
        : BaseController<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto, ProjectionFilter>(mediator);
}