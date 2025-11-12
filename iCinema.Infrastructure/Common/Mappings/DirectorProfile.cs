using AutoMapper;
using iCinema.Application.DTOs.Director;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class DirectorProfile : Profile
{
    public DirectorProfile()
    {
        CreateMap<Director, DirectorDto>();
        CreateMap<DirectorDto, Director>();
        CreateMap<DirectorCreateDto, Director>();
        CreateMap<DirectorUpdateDto, Director>();
    }
}
