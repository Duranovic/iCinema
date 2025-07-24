using AutoMapper;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CinemaRepository(iCinemaDbContext context, IMapper mapper)
    : BaseRepository<Cinema, CinemaDto, CinemaCreateDto, CinemaUpdateDto>(context, mapper),
        ICinemaRepository
{
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
            context.Projections.RemoveRange(hall.Projections);
        }

        // Delete halls
        context.Halls.RemoveRange(cinema.Halls);

        // Delete cinema
        DbSet.Remove(cinema);

        await context.SaveChangesAsync(cancellationToken);

        return true;
    }
}