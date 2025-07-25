using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Create;

public class CreateProjectionCommandHandler(IProjectionRepository repository)
    : CreateHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(repository);