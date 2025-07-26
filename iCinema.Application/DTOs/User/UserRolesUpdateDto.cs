namespace iCinema.Application.DTOs.User;

public class UserRolesUpdateDto
{
    public IList<string> Roles { get; set; } = new List<string>();
}