using iCinema.Application.DTOs.User;
using MediatR;

namespace iCinema.Application.Features.Users.Commands;

public record CreateUserCommand(UserCreateDto Dto) : IRequest<UserDto>;