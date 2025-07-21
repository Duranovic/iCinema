using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICinemaRepository
{
    public Task<IEnumerable<CinemaDto>> GetAllAsync(CancellationToken cancellationToken);
    public Task<CinemaDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    public Task<IEnumerable<CinemaDto>> GetByCityAsync(Guid cityId, CancellationToken cancellationToken);
    public Task<IEnumerable<CinemaDto>> GetFilteredAsync(CinemaFilter filter, CancellationToken cancellationToken);
}