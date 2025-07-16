using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Seat
{
    public int SeatID { get; set; }

    public int HallID { get; set; }

    public int RowNumber { get; set; }

    public int SeatNumber { get; set; }

    public virtual Hall Hall { get; set; } = null!;

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
}
