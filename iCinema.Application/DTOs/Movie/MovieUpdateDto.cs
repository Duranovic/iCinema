namespace iCinema.Application.DTOs.Movie;

public class MovieUpdateDto
{
    public string Title { get; set; } = string.Empty;
    public DateOnly? ReleaseDate { get; set; }
    public int? Duration { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<Guid> GenreIds { get; set; } = [];
    public string? PosterBase64 { get; set; }
    public string? PosterMimeType { get; set; }
}