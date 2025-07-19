using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class MovieRepository(iCinemaDbContext context, IMapper mapper) : IMovieRepository
{
    public Task<IQueryable<MovieDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var query = context.Movies.ProjectTo<MovieDto>(mapper.ConfigurationProvider);
        return Task.FromResult(query);
    }
}