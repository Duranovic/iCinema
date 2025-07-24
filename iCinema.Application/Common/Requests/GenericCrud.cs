using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using MediatR;

namespace iCinema.Application.Common.Requests;

public class GetFilteredQuery<TDto, TFilter> : IRequest<PagedResult<TDto>> where TFilter : BaseFilter, new()
{
    public TFilter Filter { get; set; } = new();
}

public class GetByIdQuery<TDto> : IRequest<TDto?>
{
    public Guid Id { get; set; }
}

public class CreateCommand<TDto, TCreateDto> : IRequest<TDto>
{
    public TCreateDto Dto { get; set; } = default!;
}

public class UpdateCommand<TDto, TUpdateDto> : IRequest<TDto?>
{
    public Guid Id { get; set; }
    public TUpdateDto Dto { get; set; } = default!;
}

public class DeleteCommand<TDto> : IRequest<bool>
{
    public Guid Id { get; set; }
}