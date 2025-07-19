using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface IMovieRepository
{
    Task<List<MovieDto>> GetAllAsync(CancellationToken cancellationToken = default);
}