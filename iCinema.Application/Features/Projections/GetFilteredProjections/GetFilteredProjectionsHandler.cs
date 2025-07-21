using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Projections.GetFilteredProjectionsQuery;

public class GetFilteredProjectionsHandler(IProjectionRepository projectionRepository) : IRequestHandler<GetFilteredProjectionsQuery, IEnumerable<ProjectionDto>>
{
    public async Task<IEnumerable<ProjectionDto>> Handle(GetFilteredProjectionsQuery request, CancellationToken cancellationToken)
    {
        return await projectionRepository.GetFilteredAsync(request.Filter, cancellationToken);
    }
}