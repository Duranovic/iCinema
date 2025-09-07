using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Cinema
{
    public Guid Id { get; set; }

    public Guid CityId { get; set; }

    public string Name { get; set; } = null!;

    public string? Address { get; set; }
    
    public string? Email { get; set; } = null!;

    public string? PhoneNumber { get; set; } = null!;

    public virtual City City { get; set; } = null!;

    public virtual ICollection<Hall> Halls { get; set; } = new List<Hall>();
}
