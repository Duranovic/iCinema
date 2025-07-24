using iCinema.Application.DTOs;
using iCinema.Application.DTOs.Movie;
using iCinema.Domain.Entities;

namespace iCinema.Application.Interfaces.Repositories;

public interface IMovieRepository : IBaseRepository<MovieDto, MovieCreateDto, MovieUpdateDto>;