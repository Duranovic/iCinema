using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Director;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Directors.Delete;

public class DeleteDirectorCommandHandler(IDirectorRepository repository)
    : DeleteHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>(repository);
