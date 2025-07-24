namespace iCinema.Application.Common.Filters;

public class CinemaFilter : BaseFilter
{
    public Guid? CityId { get; set; }
    public  Guid? CountryId { get; set; }
}