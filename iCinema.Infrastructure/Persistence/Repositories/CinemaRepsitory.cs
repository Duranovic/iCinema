using AutoMapper;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;

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
}