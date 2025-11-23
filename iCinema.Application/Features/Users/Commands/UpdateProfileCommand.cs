using iCinema.Application.DTOs.User;
using MediatR;

namespace iCinema.Application.Features.Users.Commands;

public record UpdateProfileCommand(Guid UserId, UpdateProfileDto Dto) : IRequest<UserDto>;
