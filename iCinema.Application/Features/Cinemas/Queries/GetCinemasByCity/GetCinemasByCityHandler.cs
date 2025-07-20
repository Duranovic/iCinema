using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cinemas.Queries.GetCinemasByCity;

public class GetCinemasByCityHandler(ICinemaRepository cinemaRepository) : IRequestHandler<GetCinemasByCityQuery, IEnumerable<CinemaDto>>
{
       public async Task<IEnumerable<CinemaDto>> Handle(GetCinemasByCityQuery request,
              CancellationToken cancellationToken)
       {
              return await cinemaRepository.GetByCityAsync(request.CityId,  cancellationToken);
       } 
}