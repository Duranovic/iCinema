using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Create;

public class CreateCinemaCommandHandler(ICinemaRepository repository)
    : CreateHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(repository);