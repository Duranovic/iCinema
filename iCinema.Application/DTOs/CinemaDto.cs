namespace iCinema.Application.DTOs;

public class CinemaDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Address { get; set; } = string.Empty;

    public string? PhoneNumber { get; set; }

    public Guid CityId { get; set; }

    public string CityName { get; set; } = string.Empty;

    public string CountryName { get; set; } = string.Empty;
}