using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Halls.Get;

public class GetFilteredHallsCommandHandler(IHallRepository repository)
    : GetFilteredHandler<HallDto, HallCreateDto, HallUpdateDto, HallFilter>(repository);