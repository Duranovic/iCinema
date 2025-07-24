using AutoMapper;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CityRepository(iCinemaDbContext context, IMapper mapper)
    : BaseRepository<City, CityDto, CityCreateDto, CityUpdateDto>(context, mapper), ICityRepository
{
    protected override string[] SearchableFields => ["Name"];
    
    protected override IQueryable<City> AddFilter(IQueryable<City> query, BaseFilter baseFilter)
    {
        if (baseFilter is not CityFilter filter) return query;
        
        if (filter.CountryId.HasValue)
            query = query.Where(p => p.CountryId == filter.CountryId);
        return query;
    }
    
    protected override IQueryable<City> AddInclude(IQueryable<City> query)
    {
        return query.Include(item => item.Country);
    }
}