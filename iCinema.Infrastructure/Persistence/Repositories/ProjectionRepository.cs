using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ProjectionRepository(iCinemaDbContext context, IMapper mapper)
    : BaseRepository<Projection, ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto>(context, mapper),
        IProjectionRepository
{
    private readonly iCinemaDbContext _context = context;
    protected override string[] SearchableFields => ["Price"];

    protected override IQueryable<Projection> AddFilter(IQueryable<Projection> query, BaseFilter baseFilter)
    {
        if (baseFilter is ProjectionFilter filter)
        {
            if (filter.MovieId.HasValue)
                query = query.Where(p => p.MovieId == filter.MovieId);

            if (filter.CinemaId.HasValue)
                query = query.Where(p => p.Hall.CinemaId == filter.CinemaId);

            if (filter.Date.HasValue)
                query = query.Where(p => p.StartTime.Date == filter.Date.Value.Date);
        }
        return query;
    }

    protected override IQueryable<Projection> AddInclude(IQueryable<Projection> query)
    {
        return query.Include(p => p.Hall).ThenInclude(h => h.Cinema);
    }

    protected override async Task BeforeInsert(Projection entity, ProjectionCreateDto dto)
    {
        await EnsureNoOverlap(entity.HallId, entity.MovieId, entity.StartTime);
    }
    
    private async Task EnsureNoOverlap(Guid hallId, Guid movieId, DateTime startTime, Guid? projectionId = null)
    {
        var movie = await _context.Movies.FirstOrDefaultAsync(m => m.Id == movieId);
        if (movie == null)
            throw new BusinessRuleException("Selected movie does not exist.");

        var endTime = startTime.AddMinutes(movie.DurationMin);

        var overlapping = await _context.Projections
            .Include(p => p.Movie)
            .Where(p => p.HallId == hallId && (projectionId == null || p.Id != projectionId))
            .Where(p =>
                (startTime < p.StartTime.AddMinutes(p.Movie.DurationMin)) &&
                (endTime > p.StartTime))
            .AnyAsync();

        if (overlapping)
            throw new BusinessRuleException("Projection overlaps with another projection in the same hall.");
    }
}