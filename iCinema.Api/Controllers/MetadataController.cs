using iCinema.Application.DTOs.Metadata;
using iCinema.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class MetadataController(IMovieRulesService movieRulesService) : ControllerBase
{
    [HttpGet("age-ratings")]
    public async Task<ActionResult<IEnumerable<AgeRatingItemDto>>> GetAgeRatings(CancellationToken cancellationToken)
    {
        var items = await movieRulesService.GetAgeRatingsAsync(cancellationToken);
        return Ok(items);
    }
}
