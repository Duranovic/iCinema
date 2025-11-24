namespace iCinema.Application.DTOs.Reservations;

public class TicketValidationResponseDto
{
    public string Status { get; set; } = string.Empty; // "valid", "used", "invalid", "expired"
    public string Message { get; set; } = string.Empty;
    public TicketInfoDto? TicketInfo { get; set; }
}

public class TicketInfoDto
{
    public string MovieTitle { get; set; } = string.Empty;
    public string CinemaName { get; set; } = string.Empty;
    public string HallName { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public string SeatNumber { get; set; } = string.Empty;
    public decimal Price { get; set; }
}
