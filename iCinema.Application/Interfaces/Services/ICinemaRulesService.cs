namespace iCinema.Application.Interfaces.Services;

public interface ICinemaRulesService
{
    Task EnsureCinemaNameIsUnique(string name, Guid cityId, Guid? excludeId = null, CancellationToken cancellationToken = default);
}