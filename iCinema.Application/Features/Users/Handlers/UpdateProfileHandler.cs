using iCinema.Application.DTOs.User;
using iCinema.Application.Features.Users.Commands;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Users.Handlers;

public class UpdateProfileHandler(IUserRepository repository) : IRequestHandler<UpdateProfileCommand, UserDto>
{
    public async Task<UserDto> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
        => await repository.UpdateProfileAsync(request.UserId, request.Dto, cancellationToken);
}
