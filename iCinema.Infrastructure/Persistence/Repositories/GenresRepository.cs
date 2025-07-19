using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class GenresRepository(iCinemaDbContext context, IMapper mapper) : IGenresRepository
{
    public async Task<IEnumerable<GenreDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await context.Genres.ProjectTo<GenreDto>(mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }
}