using System.Security.Claims;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
[Authorize]
public class RecommendationsController(IRecommendationRepository recommendationRepository) : ControllerBase
{
    // GET /recommendations/my?top=20&cinemaId=...
    [HttpGet("my")]
    [ProducesResponseType(typeof(IEnumerable<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMy([FromQuery] int top = 20, [FromQuery] Guid? cinemaId = null, CancellationToken cancellationToken = default)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var result = await recommendationRepository.GetUserRecommendations(userId, top, cinemaId, cancellationToken);
        return Ok(result);
    }

    // GET /recommendations/similar/{movieId}?top=20
    [HttpGet("similar/{movieId:guid}")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(IEnumerable<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetSimilar(Guid movieId, [FromQuery] int top = 20, CancellationToken cancellationToken = default)
    {
        var result = await recommendationRepository.GetSimilarMovies(movieId, top, cancellationToken);
        return Ok(result);
    }
}
