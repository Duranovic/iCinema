namespace iCinema.Application.DTOs.Actor;

public class ActorCreateDto
{
    public string FullName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? PhotoBase64 { get; set; }
    public string? PhotoMimeType { get; set; }
}
