using MediatR;
using AutoMapper;
using iCinema.Application.DTOs;
using iCinema.Application.Interfaces.Repositories;

namespace iCinema.Application.Features.Movies.Queries;

public class GetAllMoviesHandler(IMovieRepository movieRepository) : IRequestHandler<GetAllMoviesQuery, IQueryable<MovieDto>>
{
    public Task<IQueryable<MovieDto>> Handle(GetAllMoviesQuery request, CancellationToken cancellationToken)
    {
        return movieRepository.GetAllAsync(cancellationToken);
    }
}