using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Projection
{
    public int ProjectionID { get; set; }

    public int MovieID { get; set; }

    public int HallID { get; set; }

    public DateTime StartTime { get; set; }

    public decimal Price { get; set; }

    public virtual Hall Hall { get; set; } = null!;

    public virtual Movie Movie { get; set; } = null!;

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
}
