using iCinema.Application.DTOs.Home;

namespace iCinema.Application.Interfaces.Repositories;

public interface IHomeKpisRepository
{
    public Task<HomeKpisDto> GetKpisAsync();
}
