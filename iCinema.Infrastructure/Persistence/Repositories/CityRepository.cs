using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CityRepository(iCinemaDbContext context, IMapper mapper) : ICityRepository
{
    public async Task<IEnumerable<CityDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await context.Cities.ProjectTo<CityDto>(mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<CityDto>> GetFilteredAsync(CityFilter filter, CancellationToken cancellationToken)
    {
        var query = context.Cities.AsQueryable();

        if (filter.CountryId.HasValue)
            query = query.Where(p => p.CountryId == filter.CountryId);

        return await query
            .ProjectTo<CityDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
}