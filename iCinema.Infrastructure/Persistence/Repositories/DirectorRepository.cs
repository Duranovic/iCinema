using iCinema.Application.DTOs.Metadata;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class DirectorRepository(iCinemaDbContext context) : IDirectorRepository
{
    private readonly iCinemaDbContext _context = context;

    public async Task<IEnumerable<DirectorItemDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Set<Director>()
            .AsNoTracking()
            .OrderBy(d => d.FullName)
            .Select(d => new DirectorItemDto
            {
                Id = d.Id,
                FullName = d.FullName
            })
            .ToListAsync(cancellationToken);
    }
}
