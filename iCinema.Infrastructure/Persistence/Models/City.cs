using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class City
{
    public Guid Id { get; set; }

    public Guid CountryId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Cinema> Cinemas { get; set; } = new List<Cinema>();

    public virtual Country Country { get; set; } = null!;
}
