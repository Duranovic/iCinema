using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Projections.GetFilteredProjectionsQuery;

public class GetFilteredProjectionsQuery : IRequest<IEnumerable<ProjectionDto>>
{
    public ProjectionFilter Filter { get; init; } = new();
}