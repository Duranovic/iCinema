using iCinema.Api.Extensions;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Reservations;
using iCinema.Application.Interfaces.Repositories;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers
{
    public class ProjectionsController(IMediator mediator, IReservationRepository reservations)
        : BaseController<ProjectionDto, ProjectionCreateDto, ProjectionUpdateDto, ProjectionFilter>(mediator)
    {
        [HttpGet("{id:guid}/seat-map")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(SeatMapDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetSeatMap(Guid id, CancellationToken ct)
        {
            var result = await reservations.GetSeatMapAsync(id, ct);
            return result == null ? this.NotFoundError(ErrorMessages.ProjectionNotFound) : Ok(result);
        }
    }
}