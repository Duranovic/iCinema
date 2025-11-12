namespace iCinema.Application.DTOs.Director;

public class DirectorCreateDto
{
    public string FullName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? PhotoUrl { get; set; }
}
