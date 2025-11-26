
namespace iCinema.Application.DTOs.Movie;

public class MovieDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateOnly? ReleaseDate { get; set; }
    public int? Duration { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? AgeRating { get; set; }
    public Guid? DirectorId { get; set; }
    public string? DirectorName { get; set; }
    public double? AverageRating { get; set; }
    public int RatingsCount { get; set; }
    public List<string> Genres { get; set; } = [];
    public string? PosterUrl { get; set; }
    public string? ThumbnailUrl { get; set; }
    public List<CastItemDto> Cast { get; set; } = [];
}