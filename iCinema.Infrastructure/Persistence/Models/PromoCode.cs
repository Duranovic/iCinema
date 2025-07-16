using System;
using System.Collections.Generic;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class PromoCode
{
    public int PromoCodeID { get; set; }

    public string Code { get; set; } = null!;

    public decimal DiscountPercent { get; set; }

    public DateTime ValidFrom { get; set; }

    public DateTime ValidTo { get; set; }

    public bool IsActive { get; set; }
}
