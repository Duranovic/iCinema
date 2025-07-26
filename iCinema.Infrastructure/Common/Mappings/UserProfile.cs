using AutoMapper;
using iCinema.Application.DTOs.User;
using iCinema.Infrastructure.Identity;

namespace iCinema.Infrastructure.Common.Mappings;

public class UserProfile : Profile
{
    public UserProfile()
    {
        CreateMap<ApplicationUser, UserDto>()
            .ForMember(dest => dest.Roles, opt => opt.Ignore()); // Populate manually
    }
}