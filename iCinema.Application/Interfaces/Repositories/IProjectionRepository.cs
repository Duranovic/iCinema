using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface IProjectionRepository 
    : IBaseRepository<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>;