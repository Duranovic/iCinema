using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Movie
{
    public int MovieID { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public int DurationMin { get; set; }

    public int GenreID { get; set; }

    public DateOnly? ReleaseDate { get; set; }

    public string? PosterUrl { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual ICollection<Projection> Projections { get; set; } = new List<Projection>();

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();
}
