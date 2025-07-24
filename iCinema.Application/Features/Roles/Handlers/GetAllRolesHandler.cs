using iCinema.Application.DTOs;
using iCinema.Application.Features.Roles.Queries;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Roles.Handlers;

public class GetAllRolesHandler(IRoleRepository roleRepository) : IRequestHandler<GetAllRolesQuery, IEnumerable<RoleDto>>
{
    public async Task<IEnumerable<RoleDto>> Handle(GetAllRolesQuery request, CancellationToken cancellationToken)
    {
        return await roleRepository.GetAllAsync(cancellationToken);
    }
}