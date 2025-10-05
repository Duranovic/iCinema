using System.Security.Claims;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.DTOs.Ratings;
using iCinema.Application.Interfaces.Repositories;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

public class MoviesController(IMediator mediator, IRatingRepository ratings)
    : BaseController<MovieDto, MovieCreateDto, MovieUpdateDto, MovieFilter>(mediator)
{
    private readonly IRatingRepository _ratings = ratings;

    [Authorize]
    [HttpGet("{movieId:guid}/my-rating")]
    [ProducesResponseType(typeof(MyRatingDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyRating(Guid movieId, CancellationToken cancellationToken = default)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var result = await _ratings.GetMyRatingAsync(userId, movieId, cancellationToken);
        if (result == null) return NoContent();
        return Ok(result);
    }

    [Authorize]
    [HttpPut("{movieId:guid}/rating")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> PutMyRating(Guid movieId, [FromBody] PutMyRatingDto dto, CancellationToken cancellationToken = default)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrWhiteSpace(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        if (dto == null || dto.RatingValue < 1 || dto.RatingValue > 5)
            return BadRequest(new { error = "RatingValue must be between 1 and 5" });

        await _ratings.UpsertMyRatingAsync(userId, movieId, dto.RatingValue, dto.Review, cancellationToken);
        return NoContent();
    }
}