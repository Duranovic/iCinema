using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Projections.GetProjectionById;

public record GetProjectionByIdQuery(Guid Id) : IRequest<ProjectionDto?>;