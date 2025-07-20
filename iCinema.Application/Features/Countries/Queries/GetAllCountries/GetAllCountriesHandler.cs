using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using MediatR;

namespace iCinema.Application.Features.Countries.Queries.GetAllCountries;

public class GetAllCountriesHandler (ICountryRepository countryRepository) : IRequestHandler<GetAllCountriesQuery, IEnumerable<CountryDto>>
{
    public async Task<IEnumerable<CountryDto>> Handle(GetAllCountriesQuery request, CancellationToken cancellationToken)
    {
        return await countryRepository.GetAllAsync(cancellationToken);
    }
}