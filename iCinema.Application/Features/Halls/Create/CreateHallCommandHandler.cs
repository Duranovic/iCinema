using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Halls.Create;

public class CreateHallCommandHandler(IHallRepository repository)
    : CreateHandler<HallDto, HallCreateDto, HallUpdateDto>(repository);