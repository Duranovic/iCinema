using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class Country
{
    public int CountryID { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<City> Cities { get; set; } = new List<City>();
}
