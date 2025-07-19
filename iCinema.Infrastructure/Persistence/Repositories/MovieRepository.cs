using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Movie = iCinema.Domain.Entities.Movie;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class MovieRepository : IMovieRepository
{
    private readonly iCinemaDbContext _context;
    private readonly IMapper _mapper;

    public MovieRepository(iCinemaDbContext context,  IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }
    public async Task<List<MovieDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        // var efMovies = await _context.Movies.ToListAsync(cancellationToken);
        // var domainMovies = _mapper.Map<List<MovieDto>>(efMovies);
        //
        //
        // return domainMovies;
        return await _context.Movies.ProjectTo<MovieDto>(_mapper.ConfigurationProvider).ToListAsync(cancellationToken);
    }
}