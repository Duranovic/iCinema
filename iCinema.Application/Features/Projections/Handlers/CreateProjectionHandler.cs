using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Handlers;

public class CreateProjectionHandler(IProjectionRepository repository)
    : CreateHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(repository);