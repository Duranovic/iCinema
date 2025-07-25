using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class RoleRepository(iCinemaDbContext context, IMapper mapper) : IRoleRepository
{
    public async Task<IEnumerable<RoleDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await context.AspNetRoles.ProjectTo<RoleDto>(mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }
}