namespace iCinema.Application.DTOs.Reservations;

public class SeatMapProjectionInfo
{
    public Guid Id { get; set; }
    public DateTime StartTime { get; set; }
    public decimal Price { get; set; }
    public string HallName { get; set; } = string.Empty;
    public string CinemaName { get; set; } = string.Empty;
    public Guid MovieId { get; set; }
    public string MovieTitle { get; set; } = string.Empty;
    public string? PosterUrl { get; set; }
}
