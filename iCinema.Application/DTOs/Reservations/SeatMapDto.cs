namespace iCinema.Application.DTOs.Reservations;

public class SeatMapDto
{
    public required SeatMapProjectionInfo Projection { get; set; }
    public required SeatMapHallInfo Hall { get; set; }
    public required List<SeatMapSeatInfo> Seats { get; set; } = new();
}
