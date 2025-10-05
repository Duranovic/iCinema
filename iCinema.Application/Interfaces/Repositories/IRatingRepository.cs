using iCinema.Application.DTOs.Ratings;

namespace iCinema.Application.Interfaces.Repositories;

public interface IRatingRepository
{
    Task<MyRatingDto?> GetMyRatingAsync(Guid userId, Guid movieId, CancellationToken cancellationToken = default);
    Task UpsertMyRatingAsync(Guid userId, Guid movieId, byte ratingValue, string? review, CancellationToken cancellationToken = default);
}
