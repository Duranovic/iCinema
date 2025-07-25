namespace iCinema.Application.Interfaces.Services;

public interface ICountryRulesService
{
    Task EnsureCountryNameIsUnique(string name, Guid? excludeId = null, CancellationToken cancellationToken = default);
}