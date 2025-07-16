using iCinema.Application.Features.Movies.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;


[ApiController]
[Route("[controller]")]
public class MoviesController : ControllerBase
{
    private readonly IMediator _mediator;

    public MoviesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _mediator.Send(new GetAllMoviesQuery());
        return Ok(result);
    }
}