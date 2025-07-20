using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Genres.Queries.GetAllGenres;

public class GetAllGenresHandler(IGenresRepository genresRepository) : IRequestHandler<GetAllGeneresQuery, IEnumerable<GenreDto>>
{
    public async Task<IEnumerable<GenreDto>> Handle(GetAllGeneresQuery request, CancellationToken cancellationToken)
    {
        return await genresRepository.GetAllAsync(cancellationToken);
    }
}