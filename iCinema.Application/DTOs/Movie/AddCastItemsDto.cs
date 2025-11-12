namespace iCinema.Application.DTOs.Movie;

public class AddCastItemsDto
{
    public List<AddCastItem> Items { get; set; } = [];
}

public class AddCastItem
{
    public Guid ActorId { get; set; }
    public string? RoleName { get; set; }
}
