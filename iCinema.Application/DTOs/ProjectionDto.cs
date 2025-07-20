namespace iCinema.Application.DTOs;

public class ProjectionDto
{
    public Guid Id { get; set; }
    public Guid MovieId { get; set; }
    public string MovieTitle { get; set; } = string.Empty;
    public Guid CinemaId { get; set; }
    public string CinemaName { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public decimal Price { get; set; }
}