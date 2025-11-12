using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Movie;
using iCinema.Domain.Entities;

namespace iCinema.Application.Interfaces.Repositories;

public interface IMovieRepository : IBaseRepository<MovieDto, MovieCreateDto, MovieUpdateDto>
{
    Task<IEnumerable<CastItemDto>> GetCastAsync(Guid movieId, CancellationToken cancellationToken);
    Task AddCastAsync(Guid movieId, List<AddCastItem> items, CancellationToken cancellationToken);
    Task UpdateCastRoleAsync(Guid movieId, Guid actorId, string? roleName, CancellationToken cancellationToken);
    Task RemoveCastAsync(Guid movieId, Guid actorId, CancellationToken cancellationToken);
}