using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Ticket
{
    public int TicketID { get; set; }

    public int ReservationID { get; set; }

    public int SeatID { get; set; }

    public string QRCode { get; set; } = null!;

    public string TicketStatus { get; set; } = null!;

    public virtual Reservation Reservation { get; set; } = null!;

    public virtual Seat Seat { get; set; } = null!;
}
