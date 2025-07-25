using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Update;

public class UpdateProjectionCommandHandler(IProjectionRepository repository)
    : UpdateHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(repository);