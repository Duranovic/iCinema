using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Projections.Handlers;

public class GetFilteredProjectionsHandler(IProjectionRepository repository)
    : GetFilteredHandler<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto, ProjectionFilter>(repository);