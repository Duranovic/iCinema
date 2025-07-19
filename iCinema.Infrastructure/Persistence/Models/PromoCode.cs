using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class PromoCode
{
    public Guid Id { get; set; }

    public string Code { get; set; } = null!;

    public decimal? DiscountPercent { get; set; }

    public DateTime? ValidFrom { get; set; }

    public DateTime? ValidTo { get; set; }

    public int? MaxUses { get; set; }

    public int? CurrentUses { get; set; }

    public Guid? AppliesToMovieId { get; set; }

    public Guid? CreatedBy { get; set; }

    public virtual Movie? AppliesToMovie { get; set; }

    public virtual User? CreatedByNavigation { get; set; }
}
