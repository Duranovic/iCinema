namespace iCinema.Application.DTOs.Reservations;

public class TicketQrDto
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
}
