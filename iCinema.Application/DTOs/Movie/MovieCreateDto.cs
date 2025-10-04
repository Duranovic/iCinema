
namespace iCinema.Application.DTOs.Movie;

public class MovieCreateDto
{
    public string Title { get; set; } = string.Empty;
    public DateOnly? ReleaseDate { get; set; }
    public int? Duration { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? AgeRating { get; set; }
    public Guid? DirectorId { get; set; }
    public List<Guid> GenreIds { get; set; } = [];
    public string? PosterBase64 { get; set; }
    public string? PosterMimeType { get; set; }
}