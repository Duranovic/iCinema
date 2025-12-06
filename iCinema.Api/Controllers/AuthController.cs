using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Auth;
using iCinema.Infrastructure.Identity;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("auth")]
[AllowAnonymous]
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
            Email = dto.Email,
            FullName = dto.FullName
        };

        var result = await userManager.CreateAsync(user, dto.Password);

        if (!result.Succeeded)
            return BadRequest(result.Errors);

        await userManager.AddToRoleAsync(user, "Customer"); // default role

        // Auto-login: issue JWT immediately
        var token = await tokenService.GenerateToken(user);
        return Ok(new AuthDto { Token = token, ExpiresAt = DateTime.UtcNow.AddHours(2) });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);
        if (user == null) return Unauthorized(ErrorMessages.InvalidCredentials);

        var result = await signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        if (!result.Succeeded) return Unauthorized(ErrorMessages.InvalidCredentials);

        var token = await tokenService.GenerateToken(user);
        return Ok(new AuthDto { Token = token, ExpiresAt = DateTime.UtcNow.AddHours(2) });
    }
    
    [HttpPost("login-admin")]
    public async Task<IActionResult> LoginAdmin(LoginDto dto)
    {
        var user = await userManager.FindByEmailAsync(dto.Email);
        if(user == null) return Unauthorized(ErrorMessages.InvalidCredentials);
        
        var result = await signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        if (!result.Succeeded) return Unauthorized(ErrorMessages.InvalidCredentials);
        
        // Get user roles
        var roles = await userManager.GetRolesAsync(user);
        
        // Only allow Admin or Staff to log in to the admin app
        if (!roles.Contains("Admin") && !roles.Contains("Staff"))
            return Unauthorized(ErrorMessages.UnauthorizedAccess);
        
        var token = await tokenService.GenerateToken(user);
        return Ok(new AuthDto { Token = token, ExpiresAt = DateTime.UtcNow.AddHours(2) });
    }
}