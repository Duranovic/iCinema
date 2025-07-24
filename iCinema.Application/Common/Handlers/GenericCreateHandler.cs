using iCinema.Application.Common.Requests;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Common.Handlers;

public class CreateHandler<TDto, TCreateDto, TUpdateDto>(IBaseRepository<TDto, TCreateDto, TUpdateDto> repository)
    : IRequestHandler<CreateCommand<TDto, TCreateDto>, TDto>
{
    public async Task<TDto> Handle(CreateCommand<TDto, TCreateDto> request, CancellationToken cancellationToken)
    {
        return await repository.CreateAsync(request.Dto, cancellationToken) ?? throw new InvalidOperationException();
    }
}