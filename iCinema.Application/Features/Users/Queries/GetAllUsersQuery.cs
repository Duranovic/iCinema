using iCinema.Application.DTOs.User;
using MediatR;

namespace iCinema.Application.Features.Users.Queries;

public record GetAllUsersQuery() : IRequest<List<UserDto>>;