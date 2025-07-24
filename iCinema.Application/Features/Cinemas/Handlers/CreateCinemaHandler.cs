using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Handlers;

public class CreateCinemaHandler(ICinemaRepository cinemaRepository) 
    : CreateHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(cinemaRepository);