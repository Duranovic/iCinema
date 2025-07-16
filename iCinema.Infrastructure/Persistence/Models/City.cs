using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class City
{
    public int CityID { get; set; }

    public int CountryID { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Cinema> Cinemas { get; set; } = new List<Cinema>();

    public virtual Country Country { get; set; } = null!;
}
