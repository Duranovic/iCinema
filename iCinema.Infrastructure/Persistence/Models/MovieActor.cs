using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class MovieActor
{
    public Guid MovieId { get; set; }

    public Guid ActorId { get; set; }

    public string? RoleName { get; set; }

    public virtual Actor Actor { get; set; } = null!;

    public virtual Movie Movie { get; set; } = null!;
}
