using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.Common.Requests;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Common.Handlers;

public class GetFilteredHandler<TDto, TCreateDto, TUpdateDto, TFilter>(
    IBaseRepository<TDto, TCreateDto, TUpdateDto> repository)
    : IRequestHandler<GetFilteredQuery<TDto, TFilter>, PagedResult<TDto>>
    where TFilter : BaseFilter, new()
{
    public async Task<PagedResult<TDto>> Handle(GetFilteredQuery<TDto, TFilter> request, CancellationToken cancellationToken)
    {
        return await repository.GetFilteredAsync(request.Filter, cancellationToken);
    }
}