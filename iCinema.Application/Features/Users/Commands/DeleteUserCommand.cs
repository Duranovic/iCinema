using MediatR;

namespace iCinema.Application.Features.Users.Commands;

public record DeleteUserCommand(Guid UserId) : IRequest<bool>;