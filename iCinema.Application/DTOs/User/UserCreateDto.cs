namespace iCinema.Application.DTOs.User;

public class UserCreateDto
{
    public string Email { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public IList<string> Roles { get; set; } = new List<string>();
}