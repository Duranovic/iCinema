using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICountryRepository
{
    Task<IEnumerable<CountryDto>> GetAllAsync(CancellationToken cancellationToken);
}