using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Movie
{
    public Guid Id { get; set; }

    public Guid GenreId { get; set; }

    public Guid? DirectorId { get; set; }

    public string Title { get; set; } = null!;

    public string? Description { get; set; }

    public int DurationMin { get; set; }

    public DateOnly? ReleaseDate { get; set; }

    public string? PosterUrl { get; set; }

    public string? AgeRating { get; set; }

    public string? Language { get; set; }

    public string? TrailerUrl { get; set; }

    public virtual Director? Director { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>();

    public virtual ICollection<Projection> Projections { get; set; } = new List<Projection>();

    public virtual ICollection<PromoCode> PromoCodes { get; set; } = new List<PromoCode>();

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();
}
