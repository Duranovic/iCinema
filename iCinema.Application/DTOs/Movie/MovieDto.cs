
namespace iCinema.Application.DTOs.Movie;

public class MovieDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Year { get; set; }
    public List<string> Genres { get; set; } = [];
}