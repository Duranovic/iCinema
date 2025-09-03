
namespace iCinema.Application.DTOs.Movie;

public class MovieDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateOnly? ReleaseDate { get; set; }
    public int? Duration { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<string> Genres { get; set; } = [];
}