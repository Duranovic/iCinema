using iCinema.Application.DTOs.Home;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("home")]
[Authorize(Roles = "Admin")]
public sealed class HomeController : ControllerBase
{
    private readonly IHomeKpisRepository _kpisRepository;

    public HomeController(IHomeKpisRepository kpisRepository)
    {
        _kpisRepository = kpisRepository;
    }

    [HttpGet("kpis")]
    public async Task<ActionResult<HomeKpisDto>> GetKpis()
    {
        var result = await _kpisRepository.GetKpisAsync();
        return Ok(result);
    }
}
