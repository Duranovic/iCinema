using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Recommendation
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid MovieId { get; set; }

    public double Score { get; set; }

    public virtual Movie Movie { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
