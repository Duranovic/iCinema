using iCinema.Application.DTOs;

namespace iCinema.Application.Interfaces.Repositories;

public interface IMovieRepository
{
    Task<IQueryable<MovieDto>> GetAll(CancellationToken cancellationToken);
}