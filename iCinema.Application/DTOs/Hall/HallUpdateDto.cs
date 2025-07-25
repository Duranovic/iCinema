namespace iCinema.Application.DTOs.Hall;

public class HallUpdateDto
{
    public string Name { get; set; } = string.Empty;
    public int RowsCount { get; set; }
    public int SeatsPerRow { get; set; }
    public string HallType { get; set; } = string.Empty;
    public string ScreenSize { get; set; } = string.Empty;
    public bool IsDolbyAtmos { get; set; }
}