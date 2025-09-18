using System.Security.Claims;
using iCinema.Application.Common.Models;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("users/me")] // nests both endpoints under users/me
[Authorize]
public class MyReservationsController(IReservationRepository reservations) : ControllerBase
{
    [HttpGet("reservations")]
    [ProducesResponseType(typeof(PagedResult<ReservationListItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyReservations([FromQuery] string status = "Active", [FromQuery] int page = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var result = await reservations.GetMyReservations(userId, status, page, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpGet("reservations/{reservationId:guid}/tickets")]
    [ProducesResponseType(typeof(IEnumerable<TicketDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTickets(Guid reservationId, CancellationToken cancellationToken = default)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var result = await reservations.GetTicketsForReservation(reservationId, userId, cancellationToken);
        return Ok(result);
    }
}
