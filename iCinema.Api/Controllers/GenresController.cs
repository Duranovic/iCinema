using iCinema.Application.DTOs;
using iCinema.Application.Features.Genres.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class GenresController (IMediator mediator) : ControllerBase
{
  [HttpGet]
  public async Task<IActionResult> GetAll(CancellationToken cancellationToken = default)
  {
    var result = await mediator.Send(new GetAllGeneresQuery(), cancellationToken);
    return Ok(result);
  }
}