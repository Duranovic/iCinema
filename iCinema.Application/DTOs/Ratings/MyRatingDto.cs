namespace iCinema.Application.DTOs.Ratings;

public class MyRatingDto
{
    public Guid MovieId { get; set; }
    public byte RatingValue { get; set; }
    public string? Review { get; set; }
    public DateTime RatedAt { get; set; }
}
