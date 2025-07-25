namespace iCinema.Application.Interfaces.Services;

public interface IGenreRulesService
{
    Task EnsureGenreNameIsUnique(string name, Guid? excludeId = null, CancellationToken cancellationToken = default);
}