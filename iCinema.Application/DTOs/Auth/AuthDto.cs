namespace iCinema.Application.DTOs.Auth;

public class AuthDto
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
}