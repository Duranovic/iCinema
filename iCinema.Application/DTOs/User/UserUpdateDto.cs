namespace iCinema.Application.DTOs.User;

public abstract class UserUpdateDto
{
    public string Email { get; set; } = string.Empty;
    public string UserName { get; set; } =  string.Empty;
}