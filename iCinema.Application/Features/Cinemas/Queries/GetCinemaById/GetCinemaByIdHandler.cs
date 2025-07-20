using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetCinemaById;

public class GetCinemaByIdHandler(ICinemaRepository cinemaRepository) : IRequestHandler<GetCinemaByIdQuery, CinemaDto?>
{
    public async Task<CinemaDto?> Handle(GetCinemaByIdQuery request, CancellationToken cancellationToken)
    {
        return await cinemaRepository.GetByIdAsync(request.Id, cancellationToken);
    }
}