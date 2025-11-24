using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services.Rules;

public class CityRulesService(iCinemaDbContext context) : ICityRulesService
{
    public async Task EnsureCityNameIsUnique(string name, Guid countryId, Guid? excludeId = null, CancellationToken cancellationToken = default)
    {
        var exists = await context.Cities
            .AnyAsync(c => c.Name == name && c.CountryId == countryId && (!excludeId.HasValue || c.Id != excludeId), cancellationToken);

        if (exists)
            throw new BusinessRuleException($"A city with the name '{name}' already exists in this country.");
    }
}