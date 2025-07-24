namespace iCinema.Application.DTOs;

public class CityUpdateDto
{
    public string Name { get; set; } = string.Empty;
    public Guid CountryId { get; set; }
}