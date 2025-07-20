using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Projections.GetAllProjections;

public record GetAllProjectionsQuery : IRequest<IEnumerable<ProjectionDto>>;