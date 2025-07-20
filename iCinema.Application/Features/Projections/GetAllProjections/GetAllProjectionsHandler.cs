using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Projections.GetAllProjections;

public class GetAllProjectionsHandler(IProjectionRepository projectionRepository) : IRequestHandler<GetAllProjectionsQuery, IEnumerable<ProjectionDto>>
{
    public async Task<IEnumerable<ProjectionDto>> Handle(GetAllProjectionsQuery request, CancellationToken cancellationToken)
    {
        return await projectionRepository.GetAllAsync(cancellationToken); 
    }
}