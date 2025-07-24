using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Handlers;


public class GetProjectionByIdHandler(IProjectionRepository repository)
    : GetByIdHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(repository);