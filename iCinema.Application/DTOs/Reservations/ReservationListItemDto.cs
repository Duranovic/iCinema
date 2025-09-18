namespace iCinema.Application.DTOs.Reservations;

public class ReservationListItemDto
{
    public Guid ReservationId { get; set; }
    public DateTime ReservedAt { get; set; }
    public bool IsCanceled { get; set; }
    public int TicketsCount { get; set; }
    public Guid ProjectionId { get; set; }
    public DateTime StartTime { get; set; }
    public string HallName { get; set; } = string.Empty;
    public string CinemaName { get; set; } = string.Empty;
    public Guid MovieId { get; set; }
    public string MovieTitle { get; set; } = string.Empty;
    public string? PosterUrl { get; set; }
}
