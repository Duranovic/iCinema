using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CountryRepository : ICountryRepository
{
    private readonly iCinemaDbContext _dbContext;
    private readonly IMapper _mapper; 
    
    public CountryRepository(iCinemaDbContext dbContext, IMapper mapper)
    {
        _dbContext = dbContext;
        _mapper = mapper;
    }
    
    public async Task<IEnumerable<CountryDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.Countries.ProjectTo<CountryDto>(_mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }
}