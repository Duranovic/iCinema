using MediatR;
using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Queries;

public class GetAllMoviesHandler : IRequestHandler<GetAllMoviesQuery, List<MovieDto>>
{
    private readonly IMovieRepository _movieRepository;
    private readonly IMapper _mapper;

    public GetAllMoviesHandler(IMovieRepository movieRepository, IMapper mapper)
    {
        _movieRepository = movieRepository;
        _mapper = mapper;
    }

    public async Task<List<MovieDto>> Handle(GetAllMoviesQuery request, CancellationToken cancellationToken)
    {
        var movies = await _movieRepository.GetAllAsync(cancellationToken);
        return _mapper.Map<List<MovieDto>>(movies);
    }
}