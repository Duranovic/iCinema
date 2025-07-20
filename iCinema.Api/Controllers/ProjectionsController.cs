using iCinema.Application.Common.Filters;
using iCinema.Application.Features.Projections.GetAllProjections;
using iCinema.Application.Features.Projections.GetFilteredProjectionsQuery;
using iCinema.Application.Features.Projections.GetProjectionById;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class ProjectionsController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetAllProjectionsQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetProjectionByIdQuery(id),  cancellationToken);
        if (result is null)
        {
            return NotFound();
        }
        return Ok(result);
    }

    [HttpGet("filter")]
    public async Task<IActionResult> Filter([FromQuery] ProjectionFilter filter, CancellationToken cancellationToken)
    {
        var query = new GetFilteredProjectionsQuery { Filter = filter };
        var result = await mediator.Send(query, cancellationToken);
        
        return Ok(result);
    }
}