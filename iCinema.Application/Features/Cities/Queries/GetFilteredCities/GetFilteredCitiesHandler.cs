using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries.GetFilteredCities;

public class GetFilteredCitiesHandler(ICityRepository cityRepository) : IRequestHandler<GetFilteredCitiesQuery, IEnumerable<CityDto>>
{
    public async Task<IEnumerable<CityDto>> Handle(GetFilteredCitiesQuery request, CancellationToken cancellationToken)
    {
        return await cityRepository.GetFilteredAsync(request.CityFilter ,cancellationToken);
    }
}