using iCinema.Application.DTOs.User;
using iCinema.Application.Features.Users.Commands;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Users.Handlers;

public class CreateUserHandler(IUserRepository repository) : IRequestHandler<CreateUserCommand, UserDto>
{
    public async Task<UserDto> Handle(CreateUserCommand request, CancellationToken cancellationToken)
        => await repository.CreateAsync(request.Dto, cancellationToken);
}