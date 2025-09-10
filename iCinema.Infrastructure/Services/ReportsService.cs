using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Services;

public class ReportsService : IReportsService
{
    private readonly iCinemaDbContext _context;

    public ReportsService(iCinemaDbContext context)
    {
        _context = context;
    }

    public async Task<List<Dictionary<string, object>>> GenerateMovieReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken)
    {
        var projections = await _context.Projections
            .Include(p => p.Movie)
            .Include(p => p.Reservations)
                .ThenInclude(r => r.Tickets)
            .Where(p => p.StartTime >= from && p.StartTime <= to)
            .ToListAsync(cancellationToken);
        
        var movieGroups = projections
            .GroupBy(p => new { p.MovieId, p.Movie.Title })
            .Select(g => new Dictionary<string, object>
            {
                ["name"] = g.Key.Title,
                ["projections"] = g.Count(),
                ["reservations"] = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count)),
                ["revenue"] = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count) * p.Price)
            })
            .ToList();

        return movieGroups;
    }

    public async Task<List<Dictionary<string, object>>> GenerateMovieSalesReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken)
    {
        var projections = await _context.Projections
            .Include(p => p.Movie)
            .Include(p => p.Reservations)
                .ThenInclude(r => r.Tickets)
            .Where(p => p.StartTime >= from && p.StartTime <= to)
            .ToListAsync(cancellationToken);
        
        var movieGroups = projections
            .GroupBy(p => new { p.MovieId, p.Movie.Title })
            .Select(g => 
            {
                var totalTickets = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count));
                var totalRevenue = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count) * p.Price);
                var avgPrice = totalTickets > 0 ? totalRevenue / totalTickets : 0m;
                
                return new Dictionary<string, object>
                {
                    ["name"] = g.Key.Title,
                    ["ticketsSold"] = totalTickets,
                    ["revenue"] = totalRevenue,
                    ["avgPrice"] = avgPrice
                };
            })
            .ToList();

        return movieGroups;
    }

    public async Task<List<Dictionary<string, object>>> GenerateHallReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken)
    {
        var projections = await _context.Projections
            .Include(p => p.Hall)
                .ThenInclude(h => h.Cinema)
            .Include(p => p.Reservations)
                .ThenInclude(r => r.Tickets)
            .Where(p => p.StartTime >= from && p.StartTime <= to)
            .ToListAsync(cancellationToken);
        
        var hallGroups = projections
            .GroupBy(p => new { p.HallId, HallName = p.Hall.Name, CinemaName = p.Hall.Cinema.Name, Capacity = p.Hall.RowsCount * p.Hall.SeatsPerRow })
            .Select(g => 
            {
                var totalReservations = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count));
                var totalCapacity = g.Count() * g.Key.Capacity;
                var occupancy = totalCapacity > 0 ? (double)totalReservations / totalCapacity * 100 : 0;
                
                return new Dictionary<string, object>
                {
                    ["name"] = g.Key.HallName,
                    ["cinema"] = g.Key.CinemaName,
                    ["projections"] = g.Count(),
                    ["reservations"] = totalReservations,
                    ["occupancy"] = Math.Round(occupancy, 1)
                };
            })
            .ToList();

        return hallGroups;
    }

    public async Task<List<Dictionary<string, object>>> GenerateCinemaReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken)
    {
        var projections = await _context.Projections
            .Include(p => p.Hall)
                .ThenInclude(h => h.Cinema)
                    .ThenInclude(c => c.City)
            .Include(p => p.Reservations)
                .ThenInclude(r => r.Tickets)
            .Where(p => p.StartTime >= from && p.StartTime <= to)
            .ToListAsync(cancellationToken);
        
        var cinemaGroups = projections
            .GroupBy(p => new { p.Hall.CinemaId, CinemaName = p.Hall.Cinema.Name, CityName = p.Hall.Cinema.City.Name })
            .Select(g => new Dictionary<string, object>
            {
                ["name"] = g.Key.CinemaName,
                ["city"] = g.Key.CityName,
                ["projections"] = g.Count(),
                ["reservations"] = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count)),
                ["revenue"] = g.Sum(p => p.Reservations.Sum(r => r.Tickets.Count) * p.Price)
            })
            .ToList();

        return cinemaGroups;
    }
}
