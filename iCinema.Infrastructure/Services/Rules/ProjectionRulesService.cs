using iCinema.Application.Common.Exceptions;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services.Rules;

public class ProjectionRulesService(iCinemaDbContext context) : IProjectionRulesService
{
   public async Task<bool> HasFutureProjectionsForMovie(Guid movieId, CancellationToken cancellationToken = default)
    {
        return await context.Projections
            .AnyAsync(p => p.MovieId == movieId && p.IsActive && p.StartTime > DateTime.UtcNow, cancellationToken);
    }

    public async Task<bool> HasFutureProjectionsForHall(Guid hallId, CancellationToken cancellationToken = default)
    {
        return await context.Projections
            .AnyAsync(p => p.HallId == hallId && p.IsActive && p.StartTime > DateTime.UtcNow, cancellationToken);
    }

    public async Task<bool> HasFutureProjectionsForCinema(Guid cinemaId, CancellationToken cancellationToken = default)
    {
        return await context.Projections
            .AnyAsync(p => p.Hall.CinemaId == cinemaId && p.IsActive && p.StartTime > DateTime.UtcNow, cancellationToken);
    }

    public async Task EnsureNoOverlap(Guid hallId, Guid movieId, DateTime startTime, Guid? projectionId = null, CancellationToken cancellationToken = default)
    {
        var movie = await context.Movies.FirstOrDefaultAsync(m => m.Id == movieId, cancellationToken);
        if (movie == null)
            throw new BusinessRuleException("Odabrani film ne postoji.");

        var endTime = startTime.AddMinutes(movie.DurationMin);

        var overlapping = await context.Projections
            .Include(p => p.Movie)
            .Where(p => p.HallId == hallId && (projectionId == null || p.Id != projectionId))
            .Where(p =>
                (startTime < p.StartTime.AddMinutes(p.Movie.DurationMin)) &&
                (endTime > p.StartTime))
            .AnyAsync(cancellationToken);

        if (overlapping)
            throw new BusinessRuleException("Projekcija se preklapa sa drugom projekcijom u istoj sali.");
    }

    public async Task EnsureHallHasCapacity(Guid hallId, CancellationToken cancellationToken = default)
    {
        var hall = await context.Halls.FirstOrDefaultAsync(h => h.Id == hallId, cancellationToken);
        if (hall == null)
            throw new BusinessRuleException("Odabrana sala ne postoji.");

        var capacity = hall.RowsCount * hall.SeatsPerRow;
        if (capacity <= 0)
            throw new BusinessRuleException("Odabrana sala nema kapacitet sjedišta. Molimo prvo podesite redove i sjedala.");
    }
}