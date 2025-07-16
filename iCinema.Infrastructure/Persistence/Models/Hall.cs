using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Hall
{
    public int HallID { get; set; }

    public int CinemaID { get; set; }

    public string Name { get; set; } = null!;

    public int RowsCount { get; set; }

    public int SeatsPerRow { get; set; }

    public virtual Cinema Cinema { get; set; } = null!;

    public virtual ICollection<Projection> Projections { get; set; } = new List<Projection>();

    public virtual ICollection<Seat> Seats { get; set; } = new List<Seat>();
}
