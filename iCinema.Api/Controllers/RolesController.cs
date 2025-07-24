using iCinema.Application.Features.Roles.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class RolesController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetAllRolesQuery(), cancellationToken);
        return Ok(result);
    }
}