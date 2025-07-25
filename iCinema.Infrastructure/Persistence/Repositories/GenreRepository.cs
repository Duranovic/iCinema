using AutoMapper;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;

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
}