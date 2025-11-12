using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Handlers;
using iCinema.Application.DTOs.Director;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Directors.Get;

public class GetFilteredDirectorsCommandHandler(IDirectorRepository repository)
    : GetFilteredHandler<DirectorDto, DirectorCreateDto, DirectorUpdateDto, DirectorFilter>(repository);
