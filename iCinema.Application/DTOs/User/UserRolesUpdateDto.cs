namespace iCinema.Application.DTOs.User;

public class UpdateUserRolesDto
{
    public IList<string> Roles { get; set; } = new List<string>();
}