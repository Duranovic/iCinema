using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Cienmas.Update;

public class UpdateCinemaCommandHandler(ICinemaRepository repository)
    : UpdateHandler<CinemaDto, CinemaCreateDto, CinemaUpdateDto>(repository);