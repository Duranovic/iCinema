namespace iCinema.Application.DTOs.Movie;

public class CastItemDto
{
    public Guid ActorId { get; set; }
    public string ActorName { get; set; } = string.Empty;
    public string? RoleName { get; set; }
}
