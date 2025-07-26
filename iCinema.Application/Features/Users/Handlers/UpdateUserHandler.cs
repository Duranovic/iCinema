using iCinema.Application.DTOs.User;
using iCinema.Application.Features.Users.Commands;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Users.Handlers;

public class UpdateUserRolesHandler(IUserRepository repository) : IRequestHandler<UpdateUserRolesCommand, UserDto>
{
    public async Task<UserDto> Handle(UpdateUserRolesCommand request, CancellationToken cancellationToken)
        => await repository.UpdateRolesAsync(request.UserId, request.Dto.Roles, cancellationToken);
}