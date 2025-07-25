using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Rating
{
    public Guid Id { get; set; }

    public Guid UserId { get; set; }

    public Guid MovieId { get; set; }

    public byte RatingValue { get; set; }

    public string? Review { get; set; }

    public DateTime RatedAt { get; set; }

    public virtual Movie Movie { get; set; } = null!;

    public virtual AspNetUser User { get; set; } = null!;
}
