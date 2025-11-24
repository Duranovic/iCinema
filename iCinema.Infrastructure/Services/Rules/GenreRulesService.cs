using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services.Rules;

public class GenreRulesService(iCinemaDbContext context) : IGenreRulesService
{
    public async Task EnsureGenreNameIsUnique(string name, Guid? excludeId = null, CancellationToken cancellationToken = default)
    {
        var exists = await context.Genres
            .AnyAsync(g => g.Name == name && (!excludeId.HasValue || g.Id != excludeId), cancellationToken);

        if (exists)
            throw new BusinessRuleException($"A genre with the name '{name}' already exists.");
    }
}