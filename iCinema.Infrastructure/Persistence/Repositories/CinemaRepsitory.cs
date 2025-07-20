using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CinemaRepository(iCinemaDbContext context, IMapper mapper) : ICinemaRepository
{
    public async Task<IEnumerable<CinemaDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await context.Cinemas.ProjectTo<CinemaDto>(mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }

    public async Task<CinemaDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await context.Cinemas
            .Where(c => c.Id == id)
            .ProjectTo<CinemaDto>(mapper.ConfigurationProvider)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IEnumerable<CinemaDto>> GetByCityAsync(Guid cityId, CancellationToken cancellationToken)
    {
        return await context.Cinemas
            .Where(c => c.CityId == cityId)
            .ProjectTo<CinemaDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
}