using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Halls.Delete;

public class DeleteHallCommandHandler(IHallRepository repository)
    : DeleteHandler<HallDto, HallCreateDto, HallUpdateDto>(repository);