using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.Features.Projections.GetFilteredProjectionsQuery;

namespace iCinema.Application.Interfaces.Repositories;

public interface IProjectionRepository
{
    public Task<IEnumerable<ProjectionDto>> GetAllAsync(CancellationToken cancellationToken);
    public Task<ProjectionDto?> GetByIdAsync(Guid movieId, CancellationToken cancellationToken);
    public Task<IEnumerable<ProjectionDto>> GetFilteredAsync(ProjectionFilter filter, CancellationToken cancellationToken);
}