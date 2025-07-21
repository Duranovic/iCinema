using iCinema.Application.Common.Filters;
using iCinema.Application.Features.Cinemas.Queries.GetAllCinemas;
using iCinema.Application.Features.Cinemas.Queries.GetCinemaById;
using iCinema.Application.Features.Cinemas.Queries.GetFilteredCinemas;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class CinemasController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetAllCinemasQuery(), cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetCinemaByIdQuery(id),  cancellationToken);
        
        if (result == null)
        {
            return NotFound();
        }
        return Ok(result);
    }

    [HttpGet("filter")]
    public async Task<IActionResult> Filter([FromQuery] CinemaFilter filter, CancellationToken cancellationToken)
    {
        var query = new GetFilteredCinemasQuery { Filter = filter };
        var result = await mediator.Send(new GetFilteredCinemasQuery(), cancellationToken);
        
        return Ok(result);
    }
}   