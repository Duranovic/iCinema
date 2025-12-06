using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Actor;
using iCinema.Application.Interfaces.Repositories;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[Route("actors")]
public class ActorsController(IMediator mediator, IActorRepository actors)
    : BaseController<ActorDto, ActorCreateDto, ActorUpdateDto, ActorFilter>(mediator)
{
    private readonly IActorRepository _actors = actors;

    [HttpGet("items")]
    public async Task<ActionResult<IEnumerable<ActorItemDto>>> GetItems(CancellationToken cancellationToken = default)
    {
        var items = await _actors.GetItemsAsync(cancellationToken);
        return Ok(items);
    }
}
