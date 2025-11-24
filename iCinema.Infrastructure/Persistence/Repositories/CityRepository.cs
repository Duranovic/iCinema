using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

    public class CityRepository(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork, ICityRulesService rules)
        : BaseRepository<City, CityDto, CityCreateDto, CityUpdateDto>(context, mapper, unitOfWork), ICityRepository
    {
    protected override string[] SearchableFields => ["Name"];
    
    protected override IQueryable<City> AddFilter(IQueryable<City> query, BaseFilter baseFilter)
    {
        if (baseFilter is not CityFilter filter) return query;
        
        if (filter.CountryId.HasValue)
            query = query.Where(p => p.CountryId == filter.CountryId);
        return query;
    }
    
    protected override async Task BeforeInsert(City entity, CityCreateDto dto)
    {
        await rules.EnsureCityNameIsUnique(dto.Name, dto.CountryId);
    }
    
    public override async Task<CityDto?> UpdateAsync(Guid id, CityUpdateDto dto, CancellationToken cancellationToken)
    {
        await rules.EnsureCityNameIsUnique(dto.Name, dto.CountryId, id, cancellationToken);
        return await base.UpdateAsync(id, dto, cancellationToken);
    }

    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var inUse = await DbSet.AnyAsync(c => c.Id == id && c.Cinemas.Any(), cancellationToken);
        if (inUse)
        {
            throw new BusinessRuleException("Ne možete obrisati grad jer je povezan s kinima.");
        }

        return await base.DeleteAsync(id, cancellationToken);
    }
}