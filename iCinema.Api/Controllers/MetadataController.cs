using iCinema.Application.DTOs.Metadata;
using iCinema.Application.Interfaces.Services;
using iCinema.Application.Interfaces.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class MetadataController(IMovieRulesService movieRulesService, IDirectorRepository directorRepository) : ControllerBase
{
    [HttpGet("age-ratings")]
    public async Task<ActionResult<IEnumerable<AgeRatingItemDto>>> GetAgeRatings(CancellationToken cancellationToken)
    {
        var items = await movieRulesService.GetAgeRatingsAsync(cancellationToken);
        return Ok(items);
    }

    [HttpGet("directors")]
    public async Task<ActionResult<IEnumerable<DirectorItemDto>>> GetDirectors(CancellationToken cancellationToken)
    {
        var items = await directorRepository.GetItemsAsync(cancellationToken);
        return Ok(items);
    }
}
