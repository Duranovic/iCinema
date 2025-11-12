namespace iCinema.Application.DTOs.Director;

public class DirectorUpdateDto
{
    public string FullName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? PhotoUrl { get; set; }
}
