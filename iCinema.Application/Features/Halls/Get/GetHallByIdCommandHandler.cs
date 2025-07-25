using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Halls.Get;

public class GetHallByIdCommandHandler(IHallRepository repository)
    : GetByIdHandler<HallDto, HallCreateDto, HallUpdateDto>(repository);