namespace iCinema.Application.DTOs.Reservations;

public class SeatMapHallInfo
{
    public Guid Id { get; set; }
    public int RowsCount { get; set; }
    public int SeatsPerRow { get; set; }
    public int Capacity { get; set; }
}
