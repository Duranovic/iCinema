using iCinema.Application.DTOs.Home;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public sealed class HomeKpisRepository : IHomeKpisRepository
{
    private readonly iCinemaDbContext _db;

    public HomeKpisRepository(iCinemaDbContext db)
    {
        _db = db;
    }

    public async Task<HomeKpisDto> GetKpisAsync(CancellationToken cancellationToken = default)
    {
        var todayUtc = DateTime.UtcNow.Date;
        var tomorrowUtc = todayUtc.AddDays(1);

        var nowUtc = DateTime.UtcNow;
        var monthStartUtc = new DateTime(nowUtc.Year, nowUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var nextMonthStartUtc = monthStartUtc.AddMonths(1);

        // Reservations today (exclude canceled if provided)
        var reservationsToday = await _db.Reservations
            .AsNoTracking()
            .CountAsync(r => r.ReservedAt >= todayUtc && r.ReservedAt < tomorrowUtc && (r.IsCanceled == null || r.IsCanceled == false), cancellationToken);

        // Revenue this month = sum of projection price per issued ticket in month range (based on reservation time)
        var revenueMonthDecimal = await (from t in _db.Tickets.AsNoTracking()
                                         join r in _db.Reservations.AsNoTracking() on t.ReservationId equals r.Id
                                         join p in _db.Projections.AsNoTracking() on r.ProjectionId equals p.Id
                                         where r.ReservedAt >= monthStartUtc && r.ReservedAt < nextMonthStartUtc
                                               && (r.IsCanceled == null || r.IsCanceled == false)
                                         select (decimal?)p.Price)
                                         .SumAsync(cancellationToken) ?? 0m;

        // Average occupancy across projections in the month
        var projectionsInMonth = await _db.Projections
            .AsNoTracking()
            .Include(p => p.Hall)
            .Where(p => p.StartTime >= monthStartUtc && p.StartTime < nextMonthStartUtc)
            .Select(p => new { p.Id, p.Hall.RowsCount, p.Hall.SeatsPerRow })
            .ToListAsync(cancellationToken);

        double avgOccupancy = 0.0;
        if (projectionsInMonth.Count > 0)
        {
            // Get tickets count grouped by projection
            var projectionIds = projectionsInMonth.Select(p => p.Id).ToList();

            var ticketsPerProjection = await (from t in _db.Tickets.AsNoTracking()
                                              join r in _db.Reservations.AsNoTracking() on t.ReservationId equals r.Id
                                              where projectionIds.Contains(r.ProjectionId)
                                                    && (r.IsCanceled == null || r.IsCanceled == false)
                                              group t by r.ProjectionId into g
                                              select new { ProjectionId = g.Key, Count = g.Count() })
                                              .ToListAsync(cancellationToken);

            var ticketsDict = ticketsPerProjection.ToDictionary(x => x.ProjectionId, x => x.Count);

            var occupancies = projectionsInMonth.Select(p =>
            {
                var capacity = Math.Max(0, p.RowsCount * p.SeatsPerRow);
                if (capacity == 0) return 0.0;
                var sold = ticketsDict.TryGetValue(p.Id, out var c) ? c : 0;
                return (double)sold / capacity * 100.0;
            }).ToList();

            if (occupancies.Count > 0)
            {
                avgOccupancy = occupancies.Average();
            }
        }

        return new HomeKpisDto
        {
            ReservationsToday = reservationsToday,
            RevenueMonth = (double)revenueMonthDecimal,
            AvgOccupancy = Math.Round(avgOccupancy, 1)
        };
    }
}
