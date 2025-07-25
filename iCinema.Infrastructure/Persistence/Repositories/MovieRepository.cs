using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class MovieRepository(iCinemaDbContext context, IMapper mapper, IProjectionRulesService projectionRulesService) : BaseRepository<Movie, MovieDto, MovieCreateDto, MovieUpdateDto>(context, mapper), IMovieRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IMapper _mapper = mapper;
    private readonly IProjectionRulesService _projectionRulesService = projectionRulesService;
    protected override string[] SearchableFields => ["Title", "Description"];
    
    protected override IQueryable<Movie> AddInclude(IQueryable<Movie> query)
    {
        return query.Include(m => m.MovieGenres)
            .ThenInclude(mg => mg.Genre);
    }
    
    protected override IQueryable<Movie> AddFilter(IQueryable<Movie> query, BaseFilter baseFilter)
    {
        if (baseFilter is not MovieFilter filter) return query;
        
        if (filter.GenreId.HasValue)
            query = query.Where(m => m.MovieGenres.Any(mg => mg.GenreId == filter.GenreId));
        if (!string.IsNullOrWhiteSpace(filter.Title))
            query = query.Where(m => m.Title.Contains(filter.Title));
        return query;
    }
    
    protected override async Task BeforeInsert(Movie entity, MovieCreateDto dto)
    {
        if (dto.GenreIds.Count != 0)
        {
            entity.MovieGenres = await _context.Genres
                .Where(g => dto.GenreIds.Contains(g.Id))
                .Select(g => new MovieGenre { GenreId = g.Id, MovieId = entity.Id })
                .ToListAsync();
        }
    }
    
    public override async Task<MovieDto?> UpdateAsync(Guid id, MovieUpdateDto dto, CancellationToken cancellationToken)
    {
        var entity = await DbSet.Include(m => m.MovieGenres)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
        if (entity == null) return null;

        // Map basic properties
        _mapper.Map(dto, entity);

        // Update genres
        entity.MovieGenres.Clear();
        if (dto.GenreIds.Count != 0)
        {
            entity.MovieGenres = await _context.Genres
                .Where(g => dto.GenreIds.Contains(g.Id))
                .Select(g => new MovieGenre { GenreId = g.Id, MovieId = entity.Id })
                .ToListAsync(cancellationToken);
        }

        await _context.SaveChangesAsync(cancellationToken);
        return _mapper.Map<MovieDto>(entity);
    }
    
    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var movie = await DbSet
            .Include(m => m.MovieGenres)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);

        if (movie == null)
            return false;

        var hasFutureProjections = await _projectionRulesService.HasFutureProjectionsForMovie(movie.Id, cancellationToken);

        if (hasFutureProjections)
            throw new BusinessRuleException("Cannot delete a movie with scheduled future projections.");

        // Remove MovieGenres entries
        _context.MovieGenres.RemoveRange(movie.MovieGenres);

        DbSet.Remove(movie);
        await _context.SaveChangesAsync(cancellationToken);

        return true;
    }
}