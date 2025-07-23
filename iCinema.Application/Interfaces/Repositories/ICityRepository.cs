using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICityRepository
{
    public Task<IEnumerable<CityDto>> GetAllAsync(CancellationToken cancellationToken);
    public Task<IEnumerable<CityDto>> GetFilteredAsync(CityFilter cityFilter, CancellationToken cancellationToken);
}