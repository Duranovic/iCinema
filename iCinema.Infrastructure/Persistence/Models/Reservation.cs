using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Reservation
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid ProjectionId { get; set; }

    public DateTime ReservedAt { get; set; }

    public DateTime? ExpiresAt { get; set; }

    public bool? IsCanceled { get; set; }

    public virtual Projection Projection { get; set; } = null!;

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual AspNetUser User { get; set; } = null!;
}
