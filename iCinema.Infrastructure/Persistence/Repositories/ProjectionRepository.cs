using AutoMapper;
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
        // Prevent overlapping projections in same hall
        var overlap = await _context.Projections.AnyAsync(p =>
            p.HallId == dto.HallId &&
            p.StartTime == dto.StartTime);

        if (overlap)
            throw new InvalidOperationException("Another projection is already scheduled at this time in the same hall.");
    }
}