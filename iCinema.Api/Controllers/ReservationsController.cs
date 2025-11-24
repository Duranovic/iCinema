using System.Security.Claims;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
[Authorize]
public class ReservationsController(IReservationRepository reservations) : ControllerBase
{
    // POST /reservations
    [HttpPost]
    [ProducesResponseType(typeof(ReservationCreatedDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Create([FromBody] ReservationCreateDto dto, CancellationToken ct)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        try
        {
            var created = await reservations.CreateAsync(userId, dto, ct);
            return Ok(created);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            // map known messages to proper codes
            if (ex.Message.Contains("Projection not found", StringComparison.OrdinalIgnoreCase))
                return NotFound(new { error = ex.Message });
            if (ex.Message.Contains("Seats already taken", StringComparison.OrdinalIgnoreCase))
                return Conflict(new { error = ex.Message });
            if (ex.Message.Contains("invalid", StringComparison.OrdinalIgnoreCase))
                return BadRequest(new { error = ex.Message });
            return BadRequest(new { error = ex.Message });
        }
    }

    // POST /reservations/{reservationId}/cancel
    [HttpPost("{reservationId:guid}/cancel")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Cancel(Guid reservationId, CancellationToken ct)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var ok = await reservations.CancelAsync(userId, reservationId, ct);
        if (!ok) return NotFound(new { error = ErrorMessages.ReservationNotFound });
        return Ok(new { success = true });
    }
}
