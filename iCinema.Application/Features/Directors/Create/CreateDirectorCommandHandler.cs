using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Director;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Directors.Create;

public class CreateDirectorCommandHandler(IDirectorRepository repository)
    : CreateHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>(repository);
