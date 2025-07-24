using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Handlers;


public class GetCinemaByIdHandler(ICinemaRepository repository)
    : GetByIdHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(repository);