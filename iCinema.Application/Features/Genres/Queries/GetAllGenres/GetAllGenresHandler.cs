using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Genres;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Genres.Queries.GetAllGenres;

public class GetAllGenresHandler(IGenreRepository genreRepository) : IRequestHandler<GetAllGeneresQuery, IEnumerable<GenreDto>>
{
    public async Task<IEnumerable<GenreDto>> Handle(GetAllGeneresQuery request, CancellationToken cancellationToken)
    {
        return await genreRepository.GetAllAsync(cancellationToken);
    }
}