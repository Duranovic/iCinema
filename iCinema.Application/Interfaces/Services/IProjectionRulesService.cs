namespace iCinema.Application.Interfaces.Services;

public interface IProjectionRulesService
{
    Task<bool> HasFutureProjectionsForMovie(Guid movieId, CancellationToken cancellationToken = default);
    Task<bool> HasFutureProjectionsForHall(Guid hallId, CancellationToken cancellationToken = default);
    Task<bool> HasFutureProjectionsForCinema(Guid cinemaId, CancellationToken cancellationToken = default);
    Task EnsureNoOverlap(Guid hallId, Guid movieId, DateTime startTime, Guid? projectionId = null, CancellationToken cancellationToken = default);
    Task EnsureHallHasCapacity(Guid hallId, CancellationToken cancellationToken = default);
}