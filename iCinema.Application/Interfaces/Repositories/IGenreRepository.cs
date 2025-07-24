using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Genres;

namespace iCinema.Application.Interfaces.Repositories;

public interface IGenreRepository : IBaseRepository<GenreDto, GenreCreateDto, GenreUpdateDto>;