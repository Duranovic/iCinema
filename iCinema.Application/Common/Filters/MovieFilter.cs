namespace iCinema.Application.Common.Filters;

public class MovieFilter : BaseFilter
{
    public Guid? GenreId { get; set; }
    public string? Title { get; set; }
}