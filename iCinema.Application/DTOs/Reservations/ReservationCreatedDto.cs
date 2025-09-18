namespace iCinema.Application.DTOs.Reservations;

public class ReservationCreatedDto
{
    public Guid ReservationId { get; set; }
    public int TicketsCount { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public decimal TotalPrice { get; set; }
}
