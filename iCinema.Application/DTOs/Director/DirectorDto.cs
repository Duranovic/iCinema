namespace iCinema.Application.DTOs.Director;

public class DirectorDto
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? PhotoUrl { get; set; }
}
