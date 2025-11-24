using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Hall : IAuditable
{
    public Guid Id { get; set; }

    public Guid CinemaId { get; set; }

    public string Name { get; set; } = null!;

    public int RowsCount { get; set; }

    public int SeatsPerRow { get; set; }

    public string? HallType { get; set; }

    public string? ScreenSize { get; set; }

    public bool? IsDolbyAtmos { get; set; }

    public virtual Cinema Cinema { get; set; } = null!;

    public virtual ICollection<Projection> Projections { get; set; } = new List<Projection>();

    public virtual ICollection<Seat> Seats { get; set; } = new List<Seat>();

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
