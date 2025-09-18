namespace iCinema.Application.DTOs.Reservations;

public class SeatMapSeatInfo
{
    public Guid SeatId { get; set; }
    public int RowNumber { get; set; }
    public int SeatNumber { get; set; }
    public bool IsTaken { get; set; }
}
