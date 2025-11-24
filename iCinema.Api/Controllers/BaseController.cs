using iCinema.Api.Extensions;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.Common.Requests;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseController<TDto, TCreateDto, TUpdateDto, TFilter>(IMediator mediator)
        : ControllerBase
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
        where TFilter : BaseFilter, new()
    {
        [HttpGet]
        public async Task<ActionResult<PagedResult<TDto>>> GetAll([FromQuery] TFilter filter, CancellationToken cancellationToken)
        {
            var query = new GetFilteredQuery<TDto, TFilter> { Filter = filter };
            var result = await mediator.Send(query, cancellationToken);
            return Ok(result);
        }

        [HttpGet("{id:guid}")]
        public async Task<ActionResult<TDto>> GetById(Guid id, CancellationToken cancellationToken)
        {
            var query = new GetByIdQuery<TDto> { Id = id };
            var result = await mediator.Send(query, cancellationToken);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<TDto>> Create([FromBody] TCreateDto dto, CancellationToken cancellationToken)
        {
            var command = new CreateCommand<TDto, TCreateDto> { Dto = dto };
            var result = await mediator.Send(command, cancellationToken);
            return CreatedAtAction(nameof(GetById), new { id = GetEntityId(result) }, result);
        }

        [HttpPut("{id:guid}")]
        public async Task<ActionResult<TDto>> Update(Guid id, [FromBody] TUpdateDto dto, CancellationToken cancellationToken)
        {
            var command = new UpdateCommand<TDto, TUpdateDto> { Id = id, Dto = dto };
            var result = await mediator.Send(command, cancellationToken);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpDelete("{id:guid}")]
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
