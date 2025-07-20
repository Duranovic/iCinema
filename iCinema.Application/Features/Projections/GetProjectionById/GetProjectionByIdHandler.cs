using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Projections.GetProjectionById;

public class GetProjectionByIdHandler(IProjectionRepository projectionRepository) : IRequestHandler<GetProjectionByIdQuery, ProjectionDto?>
{
    public async Task<ProjectionDto?> Handle(GetProjectionByIdQuery request, CancellationToken cancellationToken)
    {
        return await projectionRepository.GetByIdAsync(request.Id,  cancellationToken);
    }
}