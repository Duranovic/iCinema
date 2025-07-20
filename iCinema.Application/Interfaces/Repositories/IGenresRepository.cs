using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface IGenresRepository
{
    Task<IEnumerable<GenreDto>> GetAllAsync(CancellationToken cancellationToken);
}