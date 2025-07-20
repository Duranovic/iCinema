using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Roles.Queries.GetAllRoles;

public record GetAllRolesQuery : IRequest<IEnumerable<RoleDto>>;