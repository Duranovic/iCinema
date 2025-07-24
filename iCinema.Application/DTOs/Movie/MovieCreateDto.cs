
namespace iCinema.Application.DTOs.Movie;

public class MovieCreateDto
{
    public string Title { get; set; } = string.Empty;
    public int Year { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<Guid> GenreIds { get; set; } = [];
}