namespace iCinema.Application.DTOs.Actor;

public class ActorUpdateDto
{
    public string? FullName { get; set; }
    public string? Bio { get; set; }
    public string? PhotoBase64 { get; set; }
    public string? PhotoMimeType { get; set; }
}
