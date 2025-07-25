using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class RoleProfile : Profile
{
    public RoleProfile()
    {
        CreateMap<ApplicationRole, RoleDto>();
        CreateMap<RoleDto, ApplicationRole>();
    }
}