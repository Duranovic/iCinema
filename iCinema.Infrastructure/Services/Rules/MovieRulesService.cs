using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Application.DTOs.Metadata;

namespace iCinema.Infrastructure.Services.Rules;

public class MovieRulesService : IMovieRulesService
{
    private static readonly HashSet<string> AllowedAgeRatings = new(StringComparer.OrdinalIgnoreCase)
    {
        "G", "PG", "PG-13", "R", "NC-17", "NR"
    };

    public Task EnsureValidAgeRating(string? ageRating, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(ageRating) && !AllowedAgeRatings.Contains(ageRating))
        {
            throw new BusinessRuleException("Neispravan rejting filma. Dozvoljene vrijednosti su: G, PG, PG-13, R, NC-17, NR.");
        }
        return Task.CompletedTask;
    }

    public Task<IEnumerable<AgeRatingItemDto>> GetAgeRatingsAsync(CancellationToken cancellationToken = default)
    {
        var items = new List<AgeRatingItemDto>
        {
            new() { Code = "G", Label = "G — General audiences" },
            new() { Code = "PG", Label = "PG — Parental guidance suggested" },
            new() { Code = "PG-13", Label = "PG-13 — Parents strongly cautioned" },
            new() { Code = "R", Label = "R — Restricted" },
            new() { Code = "NC-17", Label = "NC-17 — Adults only" },
            new() { Code = "NR", Label = "NR — Not rated" }
        };
        return Task.FromResult<IEnumerable<AgeRatingItemDto>>(items);
    }
}
