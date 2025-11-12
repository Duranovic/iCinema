using AutoMapper;
using iCinema.Application.DTOs.Actor;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class ActorProfile : Profile
{
    public ActorProfile()
    {
        CreateMap<Actor, ActorDto>();
        CreateMap<ActorCreateDto, Actor>();
        CreateMap<ActorUpdateDto, Actor>();
    }
}
