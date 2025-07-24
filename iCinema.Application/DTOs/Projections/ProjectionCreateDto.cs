namespace iCinema.Application.DTOs;

public class ProjectionCreateDto
{
    public Guid MovieId { get; set; }
    public Guid HallId { get; set; }
    public DateTime StartTime { get; set; }
    public decimal Price { get; set; }
}