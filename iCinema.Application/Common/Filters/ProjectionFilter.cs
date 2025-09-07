namespace iCinema.Application.Common.Filters;

public class ProjectionFilter : BaseFilter
{
    public Guid? MovieId { get; set; }
    public Guid? CinemaId { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}