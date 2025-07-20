using iCinema.Application.Features.Cities.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;


[ApiController]
[Route("[controller]")]
public class CitiesController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken = default)
    {
        var result = await mediator.Send(new GetAllCitiesQuery(),  cancellationToken);
        return Ok(result);
    }

    [HttpGet("by-country/{countryId:guid}")]
    public async Task<IActionResult> GetByCountry(Guid countryId, CancellationToken cancellationToken = default)
    {
        var query = new GetCitiesByCountryQuery(countryId);
        var result = await mediator.Send(query, cancellationToken);
        return Ok(result);
    }
}