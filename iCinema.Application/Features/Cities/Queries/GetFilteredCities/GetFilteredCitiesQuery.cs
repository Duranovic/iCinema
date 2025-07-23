using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using MediatR;

namespace iCinema.Application.Features.Cities.Queries.GetFilteredCities;

public class GetFilteredCitiesQuery : IRequest<IEnumerable<CityDto>>
{
    public CityFilter CityFilter { get; set; } = new();
};