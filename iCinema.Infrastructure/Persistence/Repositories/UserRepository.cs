using AutoMapper;
using iCinema.Application.DTOs.User;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class UserRepository : IUserRepository
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IMapper _mapper;

    public UserRepository(UserManager<ApplicationUser> userManager, IMapper mapper)
    {
        _userManager = userManager;
        _mapper = mapper;
    }

    public async Task<List<UserDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var users = await _userManager.Users.ToListAsync(cancellationToken);
        var userDtos = _mapper.Map<List<UserDto>>(users);

        foreach (var dto in userDtos)
        {
            var user = users.First(u => u.Id == dto.Id);
            dto.Roles = await _userManager.GetRolesAsync(user);
        }

        return userDtos;
    }

    public async Task<UserDto> CreateAsync(UserCreateDto dto, CancellationToken cancellationToken)
    {
        var user = new ApplicationUser
        {
            UserName = dto.UserName,
            Email = dto.Email,
            EmailConfirmed = true
        };

        var createResult = await _userManager.CreateAsync(user, dto.Password);
        if (!createResult.Succeeded)
            throw new Exception($"Failed to create user: {string.Join(", ", createResult.Errors.Select(e => e.Description))}");

        if (dto.Roles.Any())
            await _userManager.AddToRolesAsync(user, dto.Roles);

        var resultDto = _mapper.Map<UserDto>(user);
        resultDto.Roles = await _userManager.GetRolesAsync(user);

        return resultDto;
    }
    
    public async Task<UserDto> UpdateAsync(Guid id, UserUpdateDto dto, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null) throw new Exception("User not found");

        user.Email = dto.Email;
        user.UserName = dto.UserName;

        var result = await _userManager.UpdateAsync(user);
        if (!result.Succeeded)
            throw new Exception($"Failed to update user: {string.Join(", ", result.Errors.Select(e => e.Description))}");

        var updatedDto = _mapper.Map<UserDto>(user);
        updatedDto.Roles = await _userManager.GetRolesAsync(user);
        return updatedDto;
    }

    public async Task<UserDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var user = await _userManager.Users.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);
        if (user == null) return null;

        var dto = _mapper.Map<UserDto>(user);
        dto.Roles = await _userManager.GetRolesAsync(user);
        return dto;
    }

    public async Task<UserDto> UpdateRolesAsync(Guid userId, IList<string> roles, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) throw new Exception("User not found");

        var currentRoles = await _userManager.GetRolesAsync(user);
        await _userManager.RemoveFromRolesAsync(user, currentRoles);
        await _userManager.AddToRolesAsync(user, roles);

        var dto = _mapper.Map<UserDto>(user);
        dto.Roles = roles;
        return dto;
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var user = await _userManager.FindByIdAsync(id.ToString());
        if (user == null) return false;

        var result = await _userManager.DeleteAsync(user);
        return result.Succeeded;
    }
}