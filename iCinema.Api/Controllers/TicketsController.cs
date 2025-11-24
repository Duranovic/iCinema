using System.Security.Claims;
using iCinema.Api.Extensions;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("tickets")]
public class TicketsController(ITicketRepository tickets) : ControllerBase
{
    // GET /tickets/{id}/qr - user gets their own ticket QR token
    [Authorize]
    [HttpGet("{id:guid}/qr")]
    [ProducesResponseType(typeof(TicketQrDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetQr(Guid id, CancellationToken ct)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var dto = await tickets.GetQrAsync(id, userId, ct);
        if (dto == null) return this.NotFoundError(ErrorMessages.TicketNotFound);
        return Ok(dto);
    }

    // POST /tickets/validate - staff/admin validates QR token and marks ticket used
    [Authorize(Roles = "Admin,Staff")] // adjust roles as needed
    [HttpPost("validate")]
    [ProducesResponseType(typeof(TicketValidationResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Validate([FromBody] TicketValidateRequestDto req, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(req.Token))
            return this.BadRequestError(ErrorMessages.TokenRequired);

        var result = await tickets.ValidateAsync(req.Token, ct);
        return Ok(result);
    }
}
