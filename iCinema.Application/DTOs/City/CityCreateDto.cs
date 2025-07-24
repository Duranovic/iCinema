namespace iCinema.Application.DTOs.City;

public class CityCreateDto
{
    public string Name { get; set; } = string.Empty;
    public Guid CountryId { get; set; }
}