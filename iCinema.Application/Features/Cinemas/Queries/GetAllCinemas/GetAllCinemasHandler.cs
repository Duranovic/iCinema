using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetAllCinemas;

public class GetAllCinemasHandler(ICinemaRepository cinemaRepository) : IRequestHandler<GetAllCinemasQuery, IEnumerable<CinemaDto>>
{
    public async Task<IEnumerable<CinemaDto>> Handle(GetAllCinemasQuery request, CancellationToken cancellationToken)
    {
        return await cinemaRepository.GetAllAsync(cancellationToken);
    }
}