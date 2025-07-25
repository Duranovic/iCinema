using iCinema.Application.DTOs.Hall;

namespace iCinema.Application.Interfaces.Repositories;

public interface IHallRepository : IBaseRepository<HallDto, HallCreateDto, HallUpdateDto>;