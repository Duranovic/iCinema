using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Director : IAuditable
{
    public Guid Id { get; set; }

    public string FullName { get; set; } = null!;

    public string? Bio { get; set; }

    public string? PhotoUrl { get; set; }

    public virtual ICollection<Movie> Movies { get; set; } = new List<Movie>();

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
