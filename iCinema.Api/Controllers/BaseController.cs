using iCinema.Api.Extensions;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.Common.Requests;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers
{
    /// <summary>
    /// Base controller providing CRUD operations for entities using MediatR.
    /// </summary>
    /// <typeparam name="TDto">The DTO type for entity representation.</typeparam>
    /// <typeparam name="TCreateDto">The DTO type for entity creation.</typeparam>
    /// <typeparam name="TUpdateDto">The DTO type for entity updates.</typeparam>
    /// <typeparam name="TFilter">The filter type for querying entities.</typeparam>
    [ApiController]
    [Route("[controller]")] // Note: Controllers inheriting this should override with explicit lowercase route
    [Authorize]
    public class BaseController<TDto, TCreateDto, TUpdateDto, TFilter>(IMediator mediator)
        : ControllerBase
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
        where TFilter : BaseFilter, new()
    {
        /// <summary>
        /// Gets a paginated list of entities based on the provided filter.
        /// </summary>
        /// <param name="filter">The filter criteria for querying entities.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>A paginated result of entities.</returns>
        [HttpGet]
        [AllowAnonymous]
        [ResponseCache(Duration = 60, VaryByQueryKeys = new[] { "*" })]
        public async Task<ActionResult<PagedResult<TDto>>> GetAll([FromQuery] TFilter filter, CancellationToken cancellationToken)
        {
            var query = new GetFilteredQuery<TDto, TFilter> { Filter = filter };
            var result = await mediator.Send(query, cancellationToken);
            return Ok(result);
        }

        /// <summary>
        /// Gets a single entity by its unique identifier.
        /// </summary>
        /// <param name="id">The unique identifier of the entity.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The entity if found, otherwise NotFound.</returns>
        [HttpGet("{id:guid}")]
        [AllowAnonymous]
        [ResponseCache(Duration = 300, VaryByHeader = "Authorization")]
        public async Task<ActionResult<TDto>> GetById(Guid id, CancellationToken cancellationToken)
        {
            var query = new GetByIdQuery<TDto> { Id = id };
            var result = await mediator.Send(query, cancellationToken);
            return result == null ? NotFound() : Ok(result);
        }

        /// <summary>
        /// Creates a new entity. Requires Admin role.
        /// </summary>
        /// <param name="dto">The DTO containing entity data to create.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The created entity with its location header.</returns>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<TDto>> Create([FromBody] TCreateDto dto, CancellationToken cancellationToken)
        {
            var command = new CreateCommand<TDto, TCreateDto> { Dto = dto };
            var result = await mediator.Send(command, cancellationToken);
            return CreatedAtAction(nameof(GetById), new { id = GetEntityId(result) }, result);
        }

        /// <summary>
        /// Updates an existing entity. Requires Admin role.
        /// </summary>
        /// <param name="id">The unique identifier of the entity to update.</param>
        /// <param name="dto">The DTO containing updated entity data.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>The updated entity if found, otherwise NotFound.</returns>
        [HttpPut("{id:guid}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<TDto>> Update(Guid id, [FromBody] TUpdateDto dto, CancellationToken cancellationToken)
        {
            var command = new UpdateCommand<TDto, TUpdateDto> { Id = id, Dto = dto };
            var result = await mediator.Send(command, cancellationToken);
            return result == null ? NotFound() : Ok(result);
        }

        /// <summary>
        /// Deletes an entity. Requires Admin role.
        /// </summary>
        /// <param name="id">The unique identifier of the entity to delete.</param>
        /// <param name="cancellationToken">Cancellation token.</param>
        /// <returns>NoContent if deleted successfully, otherwise NotFound.</returns>
        [HttpDelete("{id:guid}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> Delete(Guid id, CancellationToken cancellationToken)
        {
            var command = new DeleteCommand<TDto> { Id = id };
            var deleted = await mediator.Send(command, cancellationToken);
            return deleted ? NoContent() : NotFound();
        }

        private static Guid GetEntityId(TDto dto)
        {
            var prop = typeof(TDto).GetProperty("Id");
            return prop != null ? (Guid)(prop.GetValue(dto) ?? Guid.Empty) : Guid.Empty;
        }

        // Error response helpers for consistent error formatting (using extension methods)
        protected IActionResult BadRequestError(string message, IDictionary<string, string[]>? details = null)
            => this.BadRequestError(message, details);

        protected IActionResult NotFoundError(string message)
            => this.NotFoundError(message);

        protected IActionResult ConflictError(string message)
            => this.ConflictError(message);
    }
}
