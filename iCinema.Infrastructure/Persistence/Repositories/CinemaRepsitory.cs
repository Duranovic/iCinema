using AutoMapper;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CinemaRepository(iCinemaDbContext context, IMapper mapper, ICinemaRulesService rules)
    : BaseRepository<Cinema, CinemaDto, CinemaCreateDto, CinemaUpdateDto>(context, mapper),
        ICinemaRepository
{
    private readonly iCinemaDbContext _context = context;
    protected override string[] SearchableFields => ["Name", "Address"];
    
    protected override IQueryable<Cinema> AddFilter(IQueryable<Cinema> query, BaseFilter baseFilter)
    {
        if (baseFilter is not CinemaFilter filter) return query;
        
        if (filter.CountryId.HasValue)
            query = query.Where(p => p.City.CountryId == filter.CountryId);

        if (filter.CityId.HasValue)
            query = query.Where(p => p.City.Id == filter.CityId);
        return query;
    }
    
    protected override IQueryable<Cinema> AddInclude(IQueryable<Cinema> query)
    {
        return query.Include(item => item.Halls);
    }
    
    protected override async Task BeforeInsert(Cinema entity, CinemaCreateDto dto)
    {
        await rules.EnsureCinemaNameIsUnique(dto.Name, dto.CityId);
    }

    public override async Task<CinemaDto?> UpdateAsync(Guid id, CinemaUpdateDto dto, CancellationToken cancellationToken)
    {
        await rules.EnsureCinemaNameIsUnique(dto.Name, dto.CityId, id, cancellationToken);
        return await base.UpdateAsync(id, dto, cancellationToken);
    }
    
    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var cinema = await DbSet
            .Include(c => c.Halls)
            .ThenInclude(h => h.Projections)
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);

        if (cinema == null)
            return false;

        // Delete projections in each hall
        foreach (var hall in cinema.Halls)
        {
            _context.Projections.RemoveRange(hall.Projections);
        }

        // Delete halls
        _context.Halls.RemoveRange(cinema.Halls);

        // Delete cinema
        DbSet.Remove(cinema);

        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}