using iCinema.Application.DTOs.Actor;

namespace iCinema.Application.Interfaces.Repositories;

public interface IActorRepository : IBaseRepository<ActorDto, ActorCreateDto, ActorUpdateDto>
{
    Task<IEnumerable<ActorItemDto>> GetItemsAsync(CancellationToken cancellationToken = default);
}
