using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class User
{
    public int UserID { get; set; }

    public string Username { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public int RoleID { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Rating> Ratings { get; set; } = new List<Rating>();

    public virtual ICollection<Recommendation> Recommendations { get; set; } = new List<Recommendation>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual Role Role { get; set; } = null!;
}
