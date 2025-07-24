using iCinema.Application.DTOs.Cinema;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICinemaRepository: IBaseRepository<CinemaDto, CinemaCreateDto, CinemaUpdateDto>;