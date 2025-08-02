using iCinema.Application.DTOs.Auth;
using iCinema.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class AuthController(
    UserManager<ApplicationUser> userManager,
    SignInManager<ApplicationUser> signInManager,
    JwtTokenService tokenService)
    : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var user = new ApplicationUser
        {
            UserName = dto.Email,
            Email = dto.Email
        };

        var result = await userManager.CreateAsync(user, dto.Password);

        if (!result.Succeeded)
            return BadRequest(result.Errors);

        await userManager.AddToRoleAsync(user, "Customer"); // default role

        return Ok(new { message = "User registered successfully." });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);
        if (user == null) return Unauthorized("Invalid credentials.");

        var result = await signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        if (!result.Succeeded) return Unauthorized("Invalid credentials.");

        var token = await tokenService.GenerateToken(user);
        return Ok(new AuthDto { Token = token, ExpiresAt = DateTime.UtcNow.AddHours(2) });
    }
    
    [HttpPost("login-admin")]
    public async Task<IActionResult> LoginAdmin(LoginDto dto)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);
        if(user == null) return Unauthorized("Invalid credentials.");
        
        var result = await signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        if (!result.Succeeded) return Unauthorized("Invalid credentials.");
        
        // Get user roles
        var roles = await userManager.GetRolesAsync(user);
        
        // Only allow Admin or Staff to log in to the admin app
        if (!roles.Contains("Admin") && !roles.Contains("Staff"))
            return Unauthorized("You are not allowed to access the admin application.");
        
        var token = await tokenService.GenerateToken(user);
        return Ok(new AuthDto { Token = token, ExpiresAt = DateTime.UtcNow.AddHours(2) });
    }
}