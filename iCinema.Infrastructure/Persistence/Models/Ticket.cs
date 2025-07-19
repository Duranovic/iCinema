using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Ticket
{
    public Guid Id { get; set; }

    public Guid ReservationId { get; set; }

    public Guid SeatId { get; set; }

    public string? QRCode { get; set; }

    public string? TicketStatus { get; set; }

    public string? TicketType { get; set; }

    public virtual Reservation Reservation { get; set; } = null!;

    public virtual Seat Seat { get; set; } = null!;
}
