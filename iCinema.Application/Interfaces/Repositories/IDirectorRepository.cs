using iCinema.Application.DTOs.Metadata;

namespace iCinema.Application.Interfaces.Repositories;

public interface IDirectorRepository
{
    Task<IEnumerable<DirectorItemDto>> GetAllAsync(CancellationToken cancellationToken = default);
}
