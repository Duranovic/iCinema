using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Halls.Update;

public class UpdateHallCommandHandler(IHallRepository repository)
    : UpdateHandler<HallDto, HallCreateDto, HallUpdateDto>(repository);