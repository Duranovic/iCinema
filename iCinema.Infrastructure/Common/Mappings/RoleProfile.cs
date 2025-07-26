using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class RoleProfile : Profile
{
    public RoleProfile()
    {
        CreateMap<AspNetRole, RoleDto>();
        CreateMap<RoleDto, AspNetRole>();
    }
}