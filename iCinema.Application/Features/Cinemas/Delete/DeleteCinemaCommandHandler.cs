using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cinemas.Delete;

public class DeleteCinemaHandlerCommand(ICinemaRepository repository)
    : DeleteHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(repository);