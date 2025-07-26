using iCinema.Application.DTOs.User;
using MediatR;

namespace iCinema.Application.Features.Users.Commands;

public record UpdateUserRolesCommand(Guid UserId, UserRolesUpdateDto Dto) : IRequest<UserDto>;