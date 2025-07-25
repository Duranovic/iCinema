namespace iCinema.Application.DTOs.Hall;

public class HallDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int RowsCount { get; set; }
    public int SeatsPerRow { get; set; }
    public int Capacity => RowsCount * SeatsPerRow; // Auto-calculated
    public string HallType { get; set; } = string.Empty;
    public string ScreenSize { get; set; } = string.Empty;
    public bool IsDolbyAtmos { get; set; }
    public Guid CinemaId { get; set; }
    public string CinemaName { get; set; } = string.Empty;
}