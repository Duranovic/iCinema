using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Country;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class CountryRepository(iCinemaDbContext context, IMapper mapper) : BaseRepository<Country, CountryDto, CountryCreateDto, CountryUpdateDto>(context, mapper), ICountryRepository
{
    protected override string[] SearchableFields => ["Name"];
}