using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries.GetCitiesByCountry;

public class GetCitiesByCountryHandler(ICityRepository cityRepository) : IRequestHandler<GetCitiesByCountryQuery, IEnumerable<CityDto>>
{
    public async Task<IEnumerable<CityDto>> Handle(GetCitiesByCountryQuery request, CancellationToken cancellationToken)
    {
        return await cityRepository.GetAllByCountryAsync(request.CountryId,  cancellationToken);
    }
}