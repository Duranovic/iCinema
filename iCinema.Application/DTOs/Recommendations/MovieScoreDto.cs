namespace iCinema.Application.DTOs.Recommendations;

public class MovieScoreDto
{
    public Guid MovieId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? PosterUrl { get; set; }
    public List<string> Genres { get; set; } = new();
    public string? Director { get; set; }
    public List<string> TopActors { get; set; } = new();
    public double Score { get; set; }
}
