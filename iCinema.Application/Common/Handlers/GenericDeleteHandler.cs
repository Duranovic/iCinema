using iCinema.Application.Common.Requests;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Common.Handlers;

public class DeleteHandler<TDto, TCreateDto, TUpdateDto>(IBaseRepository<TDto, TCreateDto, TUpdateDto> repository)
    : IRequestHandler<DeleteCommand<TDto>, bool>
{
    public async Task<bool> Handle(DeleteCommand<TDto> request, CancellationToken cancellationToken)
    {
        return await repository.DeleteAsync(request.Id, cancellationToken);
    }
}