using iCinema.Application.Features.Roles.Queries.GetAllRoles;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class RolesController(IMediator mediator) : Controller
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await mediator.Send(new GetAllRolesQuery());
        return Ok(result);
    }
}