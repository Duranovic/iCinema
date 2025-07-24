using AutoMapper;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class GenreRepository(iCinemaDbContext context, IMapper mapper) : BaseRepository<Genre, GenreDto, GenreCreateDto, GenreUpdateDto>(context, mapper), IGenreRepository
{
    protected override string[] SearchableFields => ["Name"];
}