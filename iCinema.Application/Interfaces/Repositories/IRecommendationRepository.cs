using iCinema.Application.DTOs.Recommendations;

namespace iCinema.Application.Interfaces.Repositories;

public interface IRecommendationRepository
{
    Task<List<MovieScoreDto>> GetUserRecommendations(
        Guid userId,
        int topN = 20,
        Guid? preferredCinemaId = null,
        CancellationToken cancellationToken = default);

    Task<List<MovieScoreDto>> GetSimilarMovies(
        Guid movieId,
        int topN = 20,
        CancellationToken cancellationToken = default);
}
