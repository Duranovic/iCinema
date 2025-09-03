
namespace iCinema.Application.DTOs.Movie;

public class MovieCreateDto
{
    public string Title { get; set; } = string.Empty;
    public DateOnly? ReleaseDate { get; set; }
    public int? Duration { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<Guid> GenreIds { get; set; } = [];
}