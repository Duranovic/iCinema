using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class HallRepository(iCinemaDbContext context, IMapper mapper, IProjectionRulesService projectionRulesService) : BaseRepository<Hall, HallDto, HallCreateDto, HallUpdateDto>(context, mapper), IHallRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IMapper _mapper = mapper;
    private readonly IProjectionRulesService _projectionRulesService = projectionRulesService;
    protected override string[] SearchableFields => ["Title", "Description"];
    
    protected override IQueryable<Hall> AddInclude(IQueryable<Hall> query)
    {
        return query.Include(m => m.Cinema);
    }
    
    protected override IQueryable<Hall> AddFilter(IQueryable<Hall> query, BaseFilter baseFilter)
    {
        if (baseFilter is not HallFilter filter) return query;
        
        if (filter.CinemaId.HasValue)
            query = query.Where(m => m.CinemaId == filter.CinemaId);
        return query;
    }
    
    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var hall = await DbSet
            .Include(h => h.Projections)
            .FirstOrDefaultAsync(h => h.Id == id, cancellationToken);

        if (hall == null)
            return false;

        // Block deletion if hall has future projections
        
        var hasFutureProjections = await _projectionRulesService.HasFutureProjectionsForHall(hall.Id, cancellationToken);
        if (hasFutureProjections)
            throw new BusinessRuleException("Cannot delete a hall with scheduled future projections.");

        // Delete past projections
        _context.Projections.RemoveRange(hall.Projections);

        // Delete hall
        DbSet.Remove(hall);

        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}