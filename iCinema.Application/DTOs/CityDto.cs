namespace iCinema.Application.DTOs;

public class CityDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public Guid CountryId { get; set; }
}