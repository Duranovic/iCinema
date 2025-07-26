using iCinema.Application.DTOs.User;
using iCinema.Application.Features.Users.Queries;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Users.Handlers;

public class GetAllUsersHandler(IUserRepository repository) : IRequestHandler<GetAllUsersQuery, List<UserDto>>
{
    public async Task<List<UserDto>> Handle(GetAllUsersQuery request, CancellationToken cancellationToken)
        => await repository.GetAllAsync(cancellationToken);
}