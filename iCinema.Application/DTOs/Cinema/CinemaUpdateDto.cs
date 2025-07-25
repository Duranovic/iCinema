namespace iCinema.Application.DTOs.Cinema;

public class CinemaUpdateDto
{
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public Guid CityId { get; set; }
}