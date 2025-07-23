using iCinema.Application.Common.Filters;
using iCinema.Application.Features.Cities.Queries.GetAllCities;
using iCinema.Application.Features.Cities.Queries.GetFilteredCities;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class CitiesController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetAllCitiesQuery(),  cancellationToken);
        return Ok(result);
    }

    [HttpGet("filter")]
    public async Task<IActionResult> Filter([FromQuery] CityFilter filter ,CancellationToken cancellationToken)
    {
        var query = new GetFilteredCitiesQuery { CityFilter = filter };
        var result = await mediator.Send(query, cancellationToken);
        return Ok(result);
    }
    
}