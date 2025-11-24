using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Projection : IAuditable
{
    public Guid Id { get; set; }

    public Guid MovieId { get; set; }

    public Guid HallId { get; set; }

    public DateTime StartTime { get; set; }

    public decimal Price { get; set; }

    public bool IsActive { get; set; }

    public string? ProjectionType { get; set; }

    public bool? IsSubtitled { get; set; }

    public virtual Hall Hall { get; set; } = null!;

    public virtual Movie Movie { get; set; } = null!;

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
