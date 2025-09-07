
using iCinema.Application.DTOs.Hall;

namespace iCinema.Application.DTOs.Cinema;

public class CinemaDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Address { get; set; } = string.Empty;
    
    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    public Guid CityId { get; set; }
    public string CityName { get; set; } = string.Empty;
    public string CountryName { get; set; } = string.Empty;
    
    public virtual ICollection<HallDto> Halls { get; set; } = new List<HallDto>();
}