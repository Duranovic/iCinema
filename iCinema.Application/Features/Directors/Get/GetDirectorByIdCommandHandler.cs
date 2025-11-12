using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Director;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Directors.Get;

public class GetDirectorByIdCommandHandler(IDirectorRepository repository)
    : GetByIdHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto>(repository);
