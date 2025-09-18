using iCinema.Application.Common.Models;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ReservationRepository(iCinemaDbContext context) : IReservationRepository
{
    private readonly iCinemaDbContext _context = context;

    public async Task<PagedResult<ReservationListItemDto>> GetMyReservations(
        Guid userId,
        string status,
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var query = _context.Reservations
            .Include(r => r.Projection)
                .ThenInclude(p => p.Hall)
                    .ThenInclude(h => h.Cinema)
            .Include(r => r.Projection)
                .ThenInclude(p => p.Movie)
            .Include(r => r.Tickets)
            .Where(r => r.UserId == userId);

        // classify status
        status = (status ?? "").Trim();
        if (status.Equals("Active", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(r => (r.IsCanceled == null || r.IsCanceled == false) && r.Projection.StartTime >= now);
            query = query.OrderBy(r => r.Projection.StartTime);
        }
        else if (status.Equals("Past", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(r => (r.IsCanceled == true) || r.Projection.StartTime < now);
            query = query.OrderByDescending(r => r.Projection.StartTime);
        }
        else
        {
            // default: all, recent first
            query = query.OrderByDescending(r => r.Projection.StartTime);
        }

        var total = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(r => new ReservationListItemDto
            {
                ReservationId = r.Id,
                ReservedAt = r.ReservedAt,
                IsCanceled = r.IsCanceled ?? false,
                TicketsCount = r.Tickets.Count,
                ProjectionId = r.ProjectionId,
                StartTime = r.Projection.StartTime,
                HallName = r.Projection.Hall.Name,
                CinemaName = r.Projection.Hall.Cinema.Name,
                MovieId = r.Projection.MovieId,
                MovieTitle = r.Projection.Movie.Title,
                PosterUrl = r.Projection.Movie.PosterUrl
            })
            .ToListAsync(cancellationToken);

        return new PagedResult<ReservationListItemDto>
        {
            Items = items,
            TotalCount = total,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<List<TicketDto>> GetTicketsForReservation(Guid reservationId, Guid userId, CancellationToken cancellationToken = default)
    {
        // ensure reservation belongs to user
        var belongs = await _context.Reservations.AnyAsync(r => r.Id == reservationId && r.UserId == userId, cancellationToken);
        if (!belongs) return new List<TicketDto>();

        var tickets = await _context.Tickets
            .Include(t => t.Seat)
            .Where(t => t.ReservationId == reservationId)
            .Select(t => new TicketDto
            {
                TicketId = t.Id,
                QRCode = t.QRCode,
                TicketStatus = t.TicketStatus,
                TicketType = t.TicketType,
                RowNumber = t.Seat.RowNumber,
                SeatNumber = t.Seat.SeatNumber
            })
            .ToListAsync(cancellationToken);

        return tickets;
    }
}
