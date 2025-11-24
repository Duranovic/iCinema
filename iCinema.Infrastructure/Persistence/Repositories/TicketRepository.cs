using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using MassTransit;
using iCinema.Application.Events.Tickets;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class TicketRepository(iCinemaDbContext context, IUnitOfWork unitOfWork, IQrCodeService qr, IPublishEndpoint bus) : ITicketRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IQrCodeService _qr = qr;
    private readonly IPublishEndpoint _bus = bus;

    public async Task<TicketQrDto?> GetQrAsync(Guid ticketId, Guid userId, CancellationToken cancellationToken = default)
    {
        var ticket = await _context.Tickets
            .Include(t => t.Reservation)
            .FirstOrDefaultAsync(t => t.Id == ticketId, cancellationToken);
        if (ticket == null) return null;
        if (ticket.Reservation.UserId != userId) return null;
        if (string.IsNullOrEmpty(ticket.QRCode)) return null;

        if (!_qr.TryValidate(ticket.QRCode, out _, out _, out var exp, out _))
        {
            // If token invalid or expired, consider regenerating? For now, return null
            return null;
        }

        return new TicketQrDto
        {
            Token = ticket.QRCode!,
            ExpiresAt = exp
        };
    }

    public async Task<TicketValidationResponseDto> ValidateAsync(string token, CancellationToken cancellationToken = default)
    {
        if (!_qr.TryValidate(token, out var ticketId, out var projectionId, out var exp, out var error))
        {
            return new TicketValidationResponseDto
            {
                Status = "invalid",
                Message = error ?? "Nevažeći QR kod."
            };
        }

        var ticket = await _context.Tickets
            .Include(t => t.Reservation)
                .ThenInclude(r => r.Projection)
                    .ThenInclude(p => p.Movie)
            .Include(t => t.Reservation)
                .ThenInclude(r => r.Projection)
                    .ThenInclude(p => p.Hall)
                        .ThenInclude(h => h.Cinema)
            .Include(t => t.Seat)
            .FirstOrDefaultAsync(t => t.Id == ticketId, cancellationToken);

        if (ticket == null)
        {
            return new TicketValidationResponseDto
            {
                Status = "invalid",
                Message = "Karta nije pronađena."
            };
        }

        if (!string.Equals(ticket.QRCode, token, StringComparison.Ordinal))
        {
            return new TicketValidationResponseDto
            {
                Status = "invalid",
                Message = "QR kod se ne podudara."
            };
        }

        // Ensure projection matches (defense-in-depth)
        if (ticket.Reservation.ProjectionId != projectionId)
        {
            return new TicketValidationResponseDto
            {
                Status = "invalid",
                Message = "Projekcija se ne podudara."
            };
        }

        // Build ticket info for response
        var ticketInfo = new TicketInfoDto
        {
            MovieTitle = ticket.Reservation.Projection.Movie.Title,
            CinemaName = ticket.Reservation.Projection.Hall.Cinema.Name,
            HallName = ticket.Reservation.Projection.Hall.Name,
            StartTime = ticket.Reservation.Projection.StartTime,
            SeatNumber = $"{ticket.Seat.RowNumber}{ticket.Seat.SeatNumber}",
            Price = ticket.Reservation.Projection.Price
        };

        if (ticket.Reservation.IsCanceled == true)
        {
            return new TicketValidationResponseDto
            {
                Status = "invalid",
                Message = "Rezervacija je otkazana.",
                TicketInfo = ticketInfo
            };
        }

        if (string.Equals(ticket.TicketStatus, "Used", StringComparison.OrdinalIgnoreCase))
        {
            return new TicketValidationResponseDto
            {
                Status = "used",
                Message = "Karta je već iskorištena.",
                TicketInfo = ticketInfo
            };
        }

        // Optional: Ensure we are within a reasonable window (e.g., token expiry already enforced)
        if (exp <= DateTime.UtcNow)
        {
            return new TicketValidationResponseDto
            {
                Status = "expired",
                Message = "QR kod je istekao.",
                TicketInfo = ticketInfo
            };
        }

        // Mark as used
        ticket.TicketStatus = "Used";
        await unitOfWork.SaveChangesAsync(cancellationToken);

        // Publish TicketUsed event
        await _bus.Publish(new TicketUsed(
            ticket.Id,
            ticket.ReservationId,
            ticket.Reservation.UserId,
            ticket.Reservation.ProjectionId,
            DateTime.UtcNow
        ), cancellationToken);

        return new TicketValidationResponseDto
        {
            Status = "valid",
            Message = "Karta je validna. Dobrodošli!",
            TicketInfo = ticketInfo
        };
    }
}
