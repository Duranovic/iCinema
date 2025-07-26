using iCinema.Application.DTOs.User;
using iCinema.Application.Features.Users.Queries;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Users.Handlers;

public class GetUserByIdHandler(IUserRepository repository) : IRequestHandler<GetUserByIdQuery, UserDto>
{
    public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
        => await repository.GetByIdAsync(request.UserId, cancellationToken);
}