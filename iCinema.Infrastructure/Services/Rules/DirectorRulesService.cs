using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services.Rules;

public class DirectorRulesService(iCinemaDbContext context) : IDirectorRulesService
{
    public async Task EnsureDirectorExists(Guid? directorId, CancellationToken cancellationToken = default)
    {
        if (!directorId.HasValue)
            return; // optional, skip

        var exists = await context.Directors
            .AsNoTracking()
            .AnyAsync(d => d.Id == directorId.Value, cancellationToken);

        if (!exists)
            throw new BusinessRuleException("Režiser ne postoji.");
    }
}
