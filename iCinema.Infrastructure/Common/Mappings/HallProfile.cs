using AutoMapper;
using iCinema.Application.DTOs.Hall;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Common.Mappings;

public class HallProfile : Profile
{
    public HallProfile()
    {
        CreateMap<HallDto, Hall>();
        CreateMap<HallCreateDto, Hall>();
        CreateMap<HallUpdateDto, Hall>();
        CreateMap<Hall, HallDto>()
            .ForMember(dest => dest.CinemaName, opt => opt.MapFrom(src => src.Cinema.Name))
            .ForMember(dest => dest.Capacity, opt => opt.MapFrom(src => src.RowsCount * src.SeatsPerRow));
    }
}