using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CountryRepository(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork, ICountryRulesService rules) : BaseRepository<Country, CountryDto, CountryCreateDto, CountryUpdateDto>(context, mapper, unitOfWork), ICountryRepository
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

    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var inUse = await DbSet.AnyAsync(c => c.Id == id && c.Cities.Any(), cancellationToken);
        if (inUse)
        {
            throw new BusinessRuleException("Ne možete obrisati državu jer ima povezane gradove.");
        }

        return await base.DeleteAsync(id, cancellationToken);
    }
}