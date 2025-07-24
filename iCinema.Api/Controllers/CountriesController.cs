using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Country;
using MediatR;

namespace iCinema.Api.Controllers;

public class CountriesController(IMediator mediator)
    : BaseController<CountryDto, CountryCreateDto, CountryUpdateDto, CountryFilter>(mediator);
