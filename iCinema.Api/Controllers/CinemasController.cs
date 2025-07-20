using iCinema.Application.Features.Cinemas.Queries.GetAllCinemas;
using iCinema.Application.Features.Cinemas.Queries.GetCinemaById;
using iCinema.Application.Features.Cinemas.Queries.GetCinemasByCity;
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

    [HttpGet("cinemas/by-city/{cityId:guid}")]
    public async Task<IActionResult> GetByCity(Guid cityId, CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetCinemasByCityQuery(cityId), cancellationToken);
        return Ok(result);
    }
}   