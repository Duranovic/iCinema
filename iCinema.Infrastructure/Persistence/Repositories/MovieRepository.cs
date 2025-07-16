using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Movie = iCinema.Domain.Entities.Movie;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class MovieRepository : IMovieRepository
{
    private readonly iCinemaDbContext _context;

    public MovieRepository(iCinemaDbContext context)
    {
        _context = context;
    }
    public async Task<List<Domain.Entities.Movie>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var efMovies = await _context.Movies.ToListAsync(cancellationToken);
        
        var domainMovies = efMovies.Select(ef => new Movie(
            title: ef.Title,
            year: ef.ReleaseDate.Value.Year,
            description: ef.Description
        )).ToList();

        return domainMovies;
    }
}