using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICityRepository
{
    public Task<IEnumerable<CityDto>> GetAllAsync(CancellationToken cancellationToken);
    public Task<IEnumerable<CityDto>> GetAllByCountryAsync(Guid countryId, CancellationToken cancellationToken);
}