using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class TicketRepository(iCinemaDbContext context, IQrCodeService qr) : ITicketRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IQrCodeService _qr = qr;

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

    public async Task<(bool ok, string message)> ValidateAsync(string token, CancellationToken cancellationToken = default)
    {
        if (!_qr.TryValidate(token, out var ticketId, out var projectionId, out var exp, out var error))
        {
            return (false, error ?? "Invalid token");
        }

        var ticket = await _context.Tickets
            .Include(t => t.Reservation)
            .FirstOrDefaultAsync(t => t.Id == ticketId, cancellationToken);
        if (ticket == null) return (false, "Ticket not found");
        if (!string.Equals(ticket.QRCode, token, StringComparison.Ordinal))
            return (false, "Token mismatch");

        // Ensure projection matches (defense-in-depth)
        if (ticket.Reservation.ProjectionId != projectionId)
            return (false, "Projection mismatch");

        if (ticket.Reservation.IsCanceled == true)
            return (false, "Reservation canceled");

        if (string.Equals(ticket.TicketStatus, "Used", StringComparison.OrdinalIgnoreCase))
            return (false, "Ticket already used");

        // Optional: Ensure we are within a reasonable window (e.g., token expiry already enforced)
        if (exp <= DateTime.UtcNow)
            return (false, "QR expired");

        // Mark as used
        ticket.TicketStatus = "Used";
        await _context.SaveChangesAsync(cancellationToken);
        return (true, "OK");
    }
}
