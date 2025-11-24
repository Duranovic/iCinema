using MassTransit;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using iCinema.Infrastructure.Persistence;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("health")]
[AllowAnonymous]
public class HealthController(iCinemaDbContext db, IBus bus) : ControllerBase
{
    [HttpGet]
    public IActionResult Liveness()
    {
        return Ok(new { status = "ok" });
    }

    [HttpGet("ready")]
    public async Task<IActionResult> Readiness(CancellationToken ct)
    {
        // DB check
        try
        {
            await db.Database.ExecuteSqlRawAsync("SELECT 1", ct);
        }
        catch (Exception ex)
        {
            return StatusCode(503, new { status = "degraded", db = ex.Message });
        }

        // RabbitMQ/MassTransit basic check (bus address is configured)
        var busAddress = bus.Address?.ToString() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(busAddress))
            return StatusCode(503, new { status = "degraded", rabbit = "bus not configured" });

        return Ok(new { status = "ready", rabbit = busAddress });
    }
}
