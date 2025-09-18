namespace iCinema.Application.DTOs.Reservations;

public class TicketDto
{
    public Guid TicketId { get; set; }
    public string? QRCode { get; set; }
    public string? TicketStatus { get; set; }
    public string? TicketType { get; set; }
    public int RowNumber { get; set; }
    public int SeatNumber { get; set; }
}
