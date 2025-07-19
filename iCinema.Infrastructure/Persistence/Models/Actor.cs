using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Actor
{
    public Guid Id { get; set; }

    public string FullName { get; set; } = null!;

    public string? Bio { get; set; }

    public string? PhotoUrl { get; set; }

    public virtual ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>();
}
