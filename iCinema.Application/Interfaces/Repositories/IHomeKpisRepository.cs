using iCinema.Application.DTOs.Home;

namespace iCinema.Application.Interfaces.Repositories;

public interface IHomeKpisRepository
{
    Task<HomeKpisDto> GetKpisAsync(CancellationToken cancellationToken = default);
}
