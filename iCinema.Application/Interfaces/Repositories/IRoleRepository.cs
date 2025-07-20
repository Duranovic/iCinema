using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface IRoleRepository
{
    public Task<IEnumerable<RoleDto>> GetAllAsync(CancellationToken cancellationToken);
}   