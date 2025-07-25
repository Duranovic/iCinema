using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CountryRepository(iCinemaDbContext context, IMapper mapper, ICountryRulesService rules) : BaseRepository<Country, CountryDto, CountryCreateDto, CountryUpdateDto>(context, mapper), ICountryRepository
{
    protected override string[] SearchableFields => ["Name"];
    
    protected override async Task BeforeInsert(Country entity, CountryCreateDto dto)
    {
        await rules.EnsureCountryNameIsUnique(dto.Name);
    }
    
    public override async Task<CountryDto?> UpdateAsync(Guid id, CountryUpdateDto dto, CancellationToken cancellationToken)
    {
        await rules.EnsureCountryNameIsUnique(dto.Name, id, cancellationToken);
        return await base.UpdateAsync(id, dto, cancellationToken);
    }
}