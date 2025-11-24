using iCinema.Application.DTOs.Ratings;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class RatingRepository(iCinemaDbContext context, IUnitOfWork unitOfWork) : IRatingRepository
{
    private readonly iCinemaDbContext _context = context;

    public async Task<MyRatingDto?> GetMyRatingAsync(Guid userId, Guid movieId, CancellationToken cancellationToken = default)
    {
        var r = await _context.Set<Rating>()
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.UserId == userId && x.MovieId == movieId, cancellationToken);
        if (r == null) return null;
        return new MyRatingDto
        {
            MovieId = r.MovieId,
            RatingValue = r.RatingValue,
            Review = r.Review,
            RatedAt = r.RatedAt
        };
    }

    public async Task UpsertMyRatingAsync(Guid userId, Guid movieId, byte ratingValue, string? review, CancellationToken cancellationToken = default)
    {
        var existing = await _context.Set<Rating>()
            .FirstOrDefaultAsync(x => x.UserId == userId && x.MovieId == movieId, cancellationToken);
        if (existing == null)
        {
            var entity = new Rating
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                MovieId = movieId,
                RatingValue = ratingValue,
                Review = review,
                RatedAt = DateTime.UtcNow
            };
            _context.Set<Rating>().Add(entity);
        }
        else
        {
            existing.RatingValue = ratingValue;
            existing.Review = review;
            existing.RatedAt = DateTime.UtcNow;
        }
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }
}
