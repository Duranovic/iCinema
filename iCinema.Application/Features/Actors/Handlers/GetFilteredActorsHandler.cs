using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Actor;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Actors.Handlers;

public class GetFilteredActorsHandler(IActorRepository repository)
    : IRequestHandler<GetFilteredQuery<ActorDto, ActorFilter>, PagedResult<ActorDto>>
{
    public async Task<PagedResult<ActorDto>> Handle(GetFilteredQuery<ActorDto, ActorFilter> request, CancellationToken cancellationToken)
    {
        return await repository.GetFilteredAsync(request.Filter, cancellationToken);
    }
}
