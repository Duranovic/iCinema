using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Director;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Directors.Update;

public class UpdateDirectorCommandHandler(IDirectorRepository repository)
    : UpdateHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>(repository);
