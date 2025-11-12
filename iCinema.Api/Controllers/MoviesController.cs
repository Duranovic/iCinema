using System.Security.Claims;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.DTOs.Ratings;
using iCinema.Application.Interfaces.Repositories;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

public class MoviesController(IMediator mediator, IRatingRepository ratings, IMovieRepository movies)
    : BaseController<MovieDto, MovieCreateDto, MovieUpdateDto, MovieFilter>(mediator)
{
    private readonly IRatingRepository _ratings = ratings;
    private readonly IMovieRepository _movies = movies;

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

    // Cast management
    [HttpGet("{movieId:guid}/cast")]
    [ProducesResponseType(typeof(IEnumerable<CastItemDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetCast(Guid movieId, CancellationToken cancellationToken = default)
    {
        var cast = await _movies.GetCastAsync(movieId, cancellationToken);
        return Ok(cast);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("{movieId:guid}/cast")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> AddCast(Guid movieId, [FromBody] AddCastItemsDto dto, CancellationToken cancellationToken = default)
    {
        if (dto == null || dto.Items.Count == 0) return BadRequest(new { error = "No cast items provided" });
        await _movies.AddCastAsync(movieId, dto.Items, cancellationToken);
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{movieId:guid}/cast/{actorId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> UpdateCast(Guid movieId, Guid actorId, [FromBody] UpdateCastItemDto dto, CancellationToken cancellationToken = default)
    {
        await _movies.UpdateCastRoleAsync(movieId, actorId, dto?.RoleName, cancellationToken);
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{movieId:guid}/cast/{actorId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<IActionResult> RemoveCast(Guid movieId, Guid actorId, CancellationToken cancellationToken = default)
    {
        await _movies.RemoveCastAsync(movieId, actorId, cancellationToken);
        return NoContent();
    }
}