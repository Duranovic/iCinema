using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services;

public class CinemaRulesService(iCinemaDbContext context) : ICinemaRulesService
{
    public async Task EnsureCinemaNameIsUnique(string name, Guid cityId, Guid? excludeId = null, CancellationToken cancellationToken = default)
    {
        var exists = await context.Cinemas
            .AnyAsync(c => c.Name == name && c.CityId == cityId && (!excludeId.HasValue || c.Id != excludeId), cancellationToken);

        if (exists)
            throw new BusinessRuleException($"A cinema with the name '{name}' already exists in this city.");
    }
}