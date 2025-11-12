using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class GenreRepository(iCinemaDbContext context, IMapper mapper, IGenreRulesService rules) : BaseRepository<Genre, GenreDto, GenreCreateDto, GenreUpdateDto>(context, mapper), IGenreRepository
{
    protected override string[] SearchableFields => ["Name"];
    
    protected override async Task BeforeInsert(Genre entity, GenreCreateDto dto)
    {
        await rules.EnsureGenreNameIsUnique(dto.Name);
    }

    public override async Task<GenreDto?> UpdateAsync(Guid id, GenreUpdateDto dto, CancellationToken cancellationToken)
    {
        await rules.EnsureGenreNameIsUnique(dto.Name, id, cancellationToken);
        return await base.UpdateAsync(id, dto, cancellationToken);
    }

    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var inUse = await DbSet.AnyAsync(g => g.Id == id && g.MovieGenres.Any(), cancellationToken);
        if (inUse)
        {
            throw new BusinessRuleException("Ne možete obrisati žanr jer je povezan s filmovima.");
        }

        return await base.DeleteAsync(id, cancellationToken);
    }
}