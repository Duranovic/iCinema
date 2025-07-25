using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Get;

public class GetCinemaByIdCommandHandler(ICinemaRepository repository)
    : GetByIdHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(repository);