﻿using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Cinema
{
    public Guid Id { get; set; }

    public Guid CityId { get; set; }

    public string Name { get; set; } = null!;

    public string? Address { get; set; }

    public virtual City City { get; set; } = null!;

    public virtual ICollection<Hall> Halls { get; set; } = new List<Hall>();
}
