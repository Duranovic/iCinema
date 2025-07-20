using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries;

public class GetAllCitiesHandler(ICityRepository cityRepository) : IRequestHandler<GetAllCitiesQuery, IEnumerable<CityDto>>
{
    public async Task<IEnumerable<CityDto>> Handle(GetAllCitiesQuery request, CancellationToken cancellationToken)
    {
        return await cityRepository.GetAllAsync(cancellationToken);
    }
}