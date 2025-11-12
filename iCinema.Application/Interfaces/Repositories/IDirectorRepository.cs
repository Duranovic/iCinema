using iCinema.Application.DTOs.Metadata;
using iCinema.Application.DTOs.Director;

namespace iCinema.Application.Interfaces.Repositories;

public interface IDirectorRepository : IBaseRepository<DirectorDto, DirectorCreateDto, DirectorUpdateDto>
{
    // Lightweight list for metadata (id, name)
    Task<IEnumerable<DirectorItemDto>> GetItemsAsync(CancellationToken cancellationToken = default);
}
