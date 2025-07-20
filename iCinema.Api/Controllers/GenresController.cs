using iCinema.Application.Features.Genres.Queries.GetAllGenres;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class GenresController (IMediator mediator) : ControllerBase
{
  [HttpGet]
  public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
  {
    var result = await mediator.Send(new GetAllGeneresQuery(), cancellationToken);
    return Ok(result);
  }
}