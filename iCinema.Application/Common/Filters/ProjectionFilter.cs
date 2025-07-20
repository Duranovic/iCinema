namespace iCinema.Application.Common.Filters;

public class ProjectionFilter : BaseFilter
{
    public Guid? MovieId { get; set; }
    public Guid? CinemaId { get; set; }
    public DateTime? Date { get; set; }
}