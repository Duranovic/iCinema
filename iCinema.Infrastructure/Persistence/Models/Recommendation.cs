using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Recommendation
{
    public int RecommendationID { get; set; }

    public int UserID { get; set; }

    public int MovieID { get; set; }

    public double Score { get; set; }

    public virtual Movie Movie { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
