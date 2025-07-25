using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Delete;

public class DeleteProjectionHandlerCommand(IProjectionRepository repository)
    : DeleteHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(repository);