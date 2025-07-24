using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Handlers;

public class GetFilteredCinemasHandler(ICinemaRepository repository)
    : GetFilteredHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto, CinemaFilter>(repository);