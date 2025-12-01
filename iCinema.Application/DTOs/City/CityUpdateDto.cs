namespace iCinema.Application.DTOs.City;

public class CityUpdateDto
{
    public string Name { get; set; } = string.Empty;
    public Guid CountryId { get; set; }
}