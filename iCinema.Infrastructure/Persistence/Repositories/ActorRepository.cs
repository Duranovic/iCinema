using AutoMapper;
using iCinema.Application.DTOs.Actor;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ActorRepository(iCinemaDbContext context, IMapper mapper)
    : BaseRepository<Actor, ActorDto, ActorCreateDto, ActorUpdateDto>(context, mapper), IActorRepository
{
    protected override string[] SearchableFields => ["FullName", "Bio"];    

    public async Task<IEnumerable<ActorItemDto>> GetItemsAsync(CancellationToken cancellationToken = default)
    {
        return await DbSet
            .AsNoTracking()
            .OrderBy(a => a.FullName)
            .Select(a => new ActorItemDto
            {
                Id = a.Id,
                FullName = a.FullName
            })
            .ToListAsync(cancellationToken);
    }
}
