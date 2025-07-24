using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;
using MediatR;

namespace iCinema.Api.Controllers;

public class CitiesController(IMediator mediator)
    : BaseController<CityDto, CityCreateDto, CityUpdateDto, CityFilter>(mediator);
