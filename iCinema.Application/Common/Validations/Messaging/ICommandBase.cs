using MediatR;

namespace iCinema.Application.Common.Validations.Messaging;

public interface ICommand : IRequest, ICommandBase
{
    
}

public interface ICommand<TResponse> : IRequest<TResponse>, ICommandBase
{
    
}

public interface ICommandBase
{
    
}