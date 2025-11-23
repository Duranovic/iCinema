using iCinema.Application.DTOs.User;

namespace iCinema.Application.Interfaces.Repositories;

public interface IUserRepository
{
    Task<List<UserDto>> GetAllAsync(CancellationToken cancellationToken);
    Task<UserDto> CreateAsync(UserCreateDto dto, CancellationToken cancellationToken);
    Task<UserDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    
    Task<UserDto> UpdateAsync(Guid id, UserUpdateDto dto, CancellationToken cancellationToken);
    Task<UserDto> UpdateRolesAsync(Guid userId, IList<string> roles, CancellationToken cancellationToken);
    Task<UserDto> UpdateProfileAsync(Guid userId, UpdateProfileDto dto, CancellationToken cancellationToken);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken);
}