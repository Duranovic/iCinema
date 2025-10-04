using System;
using System.Threading;
using System.Threading.Tasks;

namespace iCinema.Application.Interfaces.Services;

public interface IDirectorRulesService
{
    Task EnsureDirectorExists(Guid? directorId, CancellationToken cancellationToken = default);
}
