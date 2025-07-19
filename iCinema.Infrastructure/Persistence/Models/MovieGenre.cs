using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class MovieGenre
{
    public Guid MovieId { get; set; }

    public Guid GenreId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual Movie Movie { get; set; } = null!;
}
