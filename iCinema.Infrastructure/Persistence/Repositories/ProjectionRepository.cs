using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using iCinema.Domain.Entities;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ProjectionRepository(iCinemaDbContext context, IMapper mapper, IProjectionRulesService projectionRules)
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

            if (filter.StartDate.HasValue && filter.EndDate.HasValue)
            {
                query = query.Where(p => p.StartTime >= filter.StartDate.Value && 
                                         p.StartTime < filter.EndDate.Value);
            }
        }
        return query;
    }

    protected override IQueryable<Projection> AddInclude(IQueryable<Projection> query)
    {
        return query.Include(p => p.Hall).ThenInclude(h => h.Cinema);
    }

    protected override async Task BeforeInsert(Projection entity, ProjectionCreateDto dto)
    {
        await projectionRules.EnsureNoOverlap(entity.HallId, entity.MovieId, entity.StartTime);
        await projectionRules.EnsureHallHasCapacity(entity.HallId);
    }
    
    public override async Task<ProjectionDto?> UpdateAsync(Guid id, ProjectionUpdateDto dto, CancellationToken cancellationToken)
    {
        var entity = await DbSet.FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
        if (entity == null) return null;

        if (entity.HallId != dto.HallId || entity.MovieId != dto.MovieId || entity.StartTime != dto.StartTime)
            await projectionRules.EnsureNoOverlap(dto.HallId, dto.MovieId, dto.StartTime, id, cancellationToken);

        await projectionRules.EnsureHallHasCapacity(dto.HallId, cancellationToken);

        mapper.Map(dto, entity);
        await _context.SaveChangesAsync(cancellationToken);
        return mapper.Map<ProjectionDto>(entity);
    }

}