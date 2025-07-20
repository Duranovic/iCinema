using AutoMapper;
using AutoMapper.QueryableExtensions;
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

    public async Task<IEnumerable<CityDto>> GetAllByCountryAsync(Guid countryId, CancellationToken cancellationToken = default)
    {
        return await  context.Cities
            .Where(c => c.CountryId == countryId)
            .ProjectTo<CityDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }
}