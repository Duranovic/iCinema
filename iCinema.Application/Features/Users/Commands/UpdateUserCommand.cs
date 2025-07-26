using iCinema.Application.DTOs.User;
using MediatR;

namespace iCinema.Application.Features.Users.Commands;

public record UpdateUserCommand(Guid UserId, UserUpdateDto Dto) : IRequest<UserDto>;
