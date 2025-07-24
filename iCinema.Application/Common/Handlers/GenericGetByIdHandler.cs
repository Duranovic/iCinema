using iCinema.Application.Common.Requests;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Common.Handlers;

public class GetByIdHandler<TDto, TCreateDto, TUpdateDto>(IBaseRepository<TDto, TCreateDto, TUpdateDto> repository)
    : IRequestHandler<GetByIdQuery<TDto>, TDto?>
{
    public async Task<TDto?> Handle(GetByIdQuery<TDto> request, CancellationToken cancellationToken)
    {
        return await repository.GetByIdAsync(request.Id, cancellationToken);
    }
}