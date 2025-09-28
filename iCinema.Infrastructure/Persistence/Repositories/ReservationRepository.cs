using iCinema.Application.Common.Models;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Models;
using iCinema.Application.Interfaces.Services;
using Microsoft.EntityFrameworkCore;
using MassTransit;
using iCinema.Application.Events.Reservations;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class ReservationRepository(iCinemaDbContext context, IQrCodeService qrCodeService, IPublishEndpoint publishEndpoint) : IReservationRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IQrCodeService _qr = qrCodeService;
    private readonly IPublishEndpoint _bus = publishEndpoint;

    public async Task<SeatMapDto?> GetSeatMapAsync(Guid projectionId, CancellationToken cancellationToken = default)
    {
        var proj = await _context.Projections
            .Include(p => p.Hall).ThenInclude(h => h.Cinema)
            .Include(p => p.Movie)
            .FirstOrDefaultAsync(p => p.Id == projectionId, cancellationToken);
        if (proj == null) return null;

        var hall = proj.Hall;

        var seats = await _context.Seats
            .Where(s => s.HallId == hall.Id)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var now = DateTime.UtcNow;
        var takenSeatIds = await _context.Tickets
            .Include(t => t.Reservation)
            .Where(t => t.Reservation.ProjectionId == projectionId
                        && (t.Reservation.IsCanceled == null || t.Reservation.IsCanceled == false)
                        && (t.Reservation.ExpiresAt == null || t.Reservation.ExpiresAt > now))
            .Select(t => t.SeatId)
            .ToListAsync(cancellationToken);
        var takenSet = takenSeatIds.ToHashSet();

        return new SeatMapDto
        {
            Projection = new SeatMapProjectionInfo
            {
                Id = proj.Id,
                StartTime = proj.StartTime,
                Price = proj.Price,
                HallName = hall.Name,
                CinemaName = hall.Cinema.Name,
                MovieId = proj.MovieId,
                MovieTitle = proj.Movie.Title,
                PosterUrl = proj.Movie.PosterUrl
            },
            Hall = new SeatMapHallInfo
            {
                Id = hall.Id,
                RowsCount = hall.RowsCount,
                SeatsPerRow = hall.SeatsPerRow,
                Capacity = hall.RowsCount * hall.SeatsPerRow
            },
            Seats = seats.Select(s => new SeatMapSeatInfo
            {
                SeatId = s.Id,
                RowNumber = s.RowNumber,
                SeatNumber = s.SeatNumber,
                IsTaken = takenSet.Contains(s.Id)
            }).OrderBy(s => s.RowNumber).ThenBy(s => s.SeatNumber).ToList()
        };
    }

    public async Task<ReservationCreatedDto> CreateAsync(Guid userId, ReservationCreateDto dto, CancellationToken cancellationToken = default)
    {
        if (dto.SeatIds == null || dto.SeatIds.Count == 0)
            throw new ArgumentException("SeatIds cannot be empty");

        await using var tx = await _context.Database.BeginTransactionAsync(cancellationToken);

        var proj = await _context.Projections
            .Include(p => p.Hall)
            .Include(p => p.Movie)
            .FirstOrDefaultAsync(p => p.Id == dto.ProjectionId, cancellationToken);
        if (proj == null) throw new InvalidOperationException("Projection not found");
        if (proj.StartTime <= DateTime.UtcNow) throw new InvalidOperationException("Projection already started");

        // validate seats belong to hall
        var hallSeatIds = await _context.Seats
            .Where(s => s.HallId == proj.HallId && dto.SeatIds.Contains(s.Id))
            .Select(s => s.Id)
            .ToListAsync(cancellationToken);
        if (hallSeatIds.Count != dto.SeatIds.Count)
            throw new InvalidOperationException("One or more seats are invalid for this hall");

        // check availability
        var now = DateTime.UtcNow;
        var conflicting = await _context.Tickets
            .Include(t => t.Reservation)
            .Where(t => t.Reservation.ProjectionId == dto.ProjectionId
                        && dto.SeatIds.Contains(t.SeatId)
                        && (t.Reservation.IsCanceled == null || t.Reservation.IsCanceled == false)
                        && (t.Reservation.ExpiresAt == null || t.Reservation.ExpiresAt > now))
            .Select(t => t.SeatId)
            .Distinct()
            .ToListAsync(cancellationToken);
        if (conflicting.Count > 0)
            throw new InvalidOperationException("Seats already taken");

        var reservation = new Reservation
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ProjectionId = dto.ProjectionId,
            ReservedAt = now,
            ExpiresAt = null,
            IsCanceled = false
        };
        await _context.Reservations.AddAsync(reservation, cancellationToken);

        // decide QR expiry: end of projection window (start + 6h)
        var qrExpires = proj.StartTime.AddHours(6);

        foreach (var seatId in dto.SeatIds)
        {
            var ticket = new Ticket
            {
                Id = Guid.NewGuid(),
                ReservationId = reservation.Id,
                SeatId = seatId,
                TicketStatus = "Active",
                TicketType = null,
                QRCode = string.Empty
            };
            // assign QR token
            ticket.QRCode = _qr.GenerateToken(ticket.Id, reservation.ProjectionId, qrExpires);
            await _context.Tickets.AddAsync(ticket, cancellationToken);
        }

        await _context.SaveChangesAsync(cancellationToken);

        // publish ReservationCreated event
        await _bus.Publish(new ReservationCreated(
            reservation.Id,
            userId,
            reservation.ProjectionId,
            proj.Movie.Title,
            proj.StartTime,
            dto.SeatIds.Count
        ), cancellationToken);

        await tx.CommitAsync(cancellationToken);

        return new ReservationCreatedDto
        {
            ReservationId = reservation.Id,
            TicketsCount = dto.SeatIds.Count,
            ExpiresAt = reservation.ExpiresAt,
            TotalPrice = proj.Price * dto.SeatIds.Count
        };
    }

    public async Task<bool> CancelAsync(Guid userId, Guid reservationId, CancellationToken cancellationToken = default)
    {
        var reservation = await _context.Reservations.FirstOrDefaultAsync(r => r.Id == reservationId && r.UserId == userId, cancellationToken);
        if (reservation == null) return false;
        if (reservation.IsCanceled == true) return true;
        if (reservation.ExpiresAt.HasValue && reservation.ExpiresAt.Value <= DateTime.UtcNow) return true; // already expired effect

        reservation.IsCanceled = true;
        await _context.SaveChangesAsync(cancellationToken);

        // publish ReservationCanceled event
        await _bus.Publish(new ReservationCanceled(
            reservation.Id,
            reservation.UserId,
            reservation.ProjectionId,
            DateTime.UtcNow
        ), cancellationToken);
        return true;
    }

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
