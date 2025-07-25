using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services;

public class CountryRulesService(iCinemaDbContext context) : ICountryRulesService
{
    public async Task EnsureCountryNameIsUnique(string name, Guid? excludeId = null, CancellationToken cancellationToken = default)
    {
        var exists = await context.Countries
            .AnyAsync(c => c.Name == name && (!excludeId.HasValue || c.Id != excludeId), cancellationToken);

        if (exists)
            throw new BusinessRuleException($"A country with the name '{name}' already exists.");
    }
}