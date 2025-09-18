namespace iCinema.Application.DTOs.Reservations;

public class ReservationCreateDto
{
    public Guid ProjectionId { get; set; }
    public List<Guid> SeatIds { get; set; } = new();
}
