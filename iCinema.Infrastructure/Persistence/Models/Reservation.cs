using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Reservation
{
    public int ReservationID { get; set; }

    public int UserID { get; set; }

    public int ProjectionID { get; set; }

    public DateTime ReservedAt { get; set; }

    public virtual Projection Projection { get; set; } = null!;

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual User User { get; set; } = null!;
}
