namespace iCinema.Application.Interfaces.Services;

public interface ICityRulesService
{
    Task EnsureCityNameIsUnique(string name, Guid countryId, Guid? excludeId = null, CancellationToken cancellationToken = default);
}