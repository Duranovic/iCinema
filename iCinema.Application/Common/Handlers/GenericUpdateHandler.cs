using iCinema.Application.Common.Requests;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Common.Handlers;

public class UpdateHandler<TDto, TCreateDto, TUpdateDto>(IBaseRepository<TDto, TCreateDto, TUpdateDto> repository)
    : IRequestHandler<UpdateCommand<TDto, TUpdateDto>, TDto?>
{
    public async Task<TDto?> Handle(UpdateCommand<TDto, TUpdateDto> request, CancellationToken cancellationToken)
    {
        return await repository.UpdateAsync(request.Id, request.Dto, cancellationToken);
    }
}