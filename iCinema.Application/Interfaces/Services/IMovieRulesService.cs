using iCinema.Application.DTOs.Metadata;

namespace iCinema.Application.Interfaces.Services;

public interface IMovieRulesService
{
    Task EnsureValidAgeRating(string? ageRating, CancellationToken cancellationToken = default);
    Task<IEnumerable<AgeRatingItemDto>> GetAgeRatingsAsync(CancellationToken cancellationToken = default);
}
