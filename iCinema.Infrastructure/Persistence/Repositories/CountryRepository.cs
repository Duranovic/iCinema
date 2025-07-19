using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CountryRepository(iCinemaDbContext context, IMapper mapper) : ICountryRepository
{
    public async Task<IEnumerable<CountryDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await context.Countries.ProjectTo<CountryDto>(mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }
}