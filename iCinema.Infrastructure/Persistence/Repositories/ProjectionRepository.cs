using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.Features.Projections.GetFilteredProjectionsQuery;
using iCinema.Application.Features.Projections.GetProjectionById;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ProjectionRepository(iCinemaDbContext context, IMapper mapper) : IProjectionRepository
{
    public async Task<IEnumerable<ProjectionDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        return await context.Projections
            .ProjectTo<ProjectionDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
    
    public async Task<ProjectionDto?> GetByIdAsync(Guid movieId, CancellationToken cancellationToken)
    {
        return await context.Projections
            .Where(p => p.MovieId == movieId)
            .ProjectTo<ProjectionDto>(mapper.ConfigurationProvider)
            .FirstOrDefaultAsync(cancellationToken);
    }
    
    public async Task<IEnumerable<ProjectionDto>> GetByMovieIdAsync(Guid movieId, CancellationToken cancellationToken)
    {
        return await context.Projections
            .Where(p => p.MovieId == movieId)
            .ProjectTo<ProjectionDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<ProjectionDto>> GetByCinemaIdAsync(Guid cinemaId, CancellationToken cancellationToken)
    {
        return await context.Projections
            .Where(p => p.Hall.CinemaId == cinemaId)
            .ProjectTo<ProjectionDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
    
    public async Task<IEnumerable<ProjectionDto>> GetFilteredAsync(ProjectionFilter filter, CancellationToken cancellationToken)
    {
        var query = context.Projections.AsQueryable();

        if (filter.MovieId.HasValue)
            query = query.Where(p => p.MovieId == filter.MovieId);

        if (filter.CinemaId.HasValue)
            query = query.Where(p => p.Hall.CinemaId == filter.CinemaId);

        if (filter.Date.HasValue)
            query = query.Where(p => p.StartTime.Date == filter.Date.Value.Date);

        return await query
            .ProjectTo<ProjectionDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
}