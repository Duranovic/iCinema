namespace iCinema.Api.Contracts.Home;

public sealed class HomeKpisDto
{
    public int ReservationsToday { get; set; }
    public double RevenueMonth { get; set; }
    public double AvgOccupancy { get; set; }
}
