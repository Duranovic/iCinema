using iCinema.Application.DTOs.Country;

namespace iCinema.Application.Interfaces.Repositories;

public interface ICountryRepository : IBaseRepository<CountryDto, CountryCreateDto, CountryUpdateDto>;