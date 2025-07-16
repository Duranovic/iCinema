using iCinema.Domain.Entities;

namespace iCinema.Application.Interfaces.Repositories;

public interface IMovieRepository
{
    Task<List<Movie>> GetAllAsync(CancellationToken cancellationToken = default);
}