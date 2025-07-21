using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetFilteredCinemas;

public class GetFilteredCinemasHandler(ICinemaRepository cinemaRepository) : IRequestHandler<GetFilteredCinemasQuery, IEnumerable<CinemaDto>>
{
    public async Task<IEnumerable<CinemaDto>> Handle(GetFilteredCinemasQuery request, CancellationToken cancellationToken)
    {
        return await cinemaRepository.GetFilteredAsync(request.Filter, cancellationToken);
    }
}