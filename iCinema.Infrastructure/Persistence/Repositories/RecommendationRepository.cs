using iCinema.Application.DTOs.Recommendations;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class RecommendationRepository : IRecommendationRepository
{
    private readonly iCinemaDbContext _context;

    public RecommendationRepository(iCinemaDbContext context)
    {
        _context = context;
    }

    public async Task<List<MovieScoreDto>> GetUserRecommendations(
        Guid userId,
        int topN = 20,
        Guid? preferredCinemaId = null,
        CancellationToken cancellationToken = default)
    {
        var movies = await _context.Movies
            .Include(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
            .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
            .Include(m => m.Director)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        if (movies.Count == 0) return new List<MovieScoreDto>();

        var itemVectors = movies.ToDictionary(m => m.Id, BuildItemVector);

        var ratings = await _context.Ratings
            .Where(r => r.UserId == userId)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var userReservations = await _context.Reservations
            .Include(r => r.Projection)
            .ThenInclude(p => p.Movie)
            .Where(r => r.UserId == userId && (r.IsCanceled == null || r.IsCanceled == false))
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var seenMovieIds = new HashSet<Guid>(ratings.Select(r => r.MovieId)
            .Concat(userReservations.Select(r => r.Projection.MovieId)));

        var profile = new Dictionary<string, double>();
        foreach (var r in ratings)
        {
            var w = Math.Max(0.2, Math.Min(1.0, r.RatingValue / 5.0));
            AddScaled(profile, itemVectors.GetValueOrDefault(r.MovieId), w);
        }
        foreach (var rez in userReservations)
        {
            var days = Math.Max(0, (DateTime.UtcNow - rez.ReservedAt).TotalDays);
            var decay = Math.Exp(-days / 90.0);
            var w = 0.6 * decay;
            AddScaled(profile, itemVectors.GetValueOrDefault(rez.Projection.MovieId), w);
        }
        Normalize(profile);

        var popularity60d = await GetPopularityScores(daysBack: 60, cancellationToken);

        var availabilityWindowTo = DateTime.UtcNow.AddDays(14);
        var availabilityMap = preferredCinemaId.HasValue
            ? await GetAvailabilityBoostMap(preferredCinemaId.Value, availabilityWindowTo, cancellationToken)
            : new Dictionary<Guid, double>();

        var results = new List<(Movie movie, double score)>();
        foreach (var m in movies)
        {
            if (seenMovieIds.Contains(m.Id)) continue;

            var sim = profile.Count == 0 ? 0.0 : Cosine(profile, itemVectors[m.Id]);
            var popularity = popularity60d.TryGetValue(m.Id, out var pop) ? pop : 0.0;
            var popularityBoost = 0.1 * Math.Tanh(popularity / 10.0);

            double freshnessBoost = 0.0;
            if (m.ReleaseDate.HasValue)
            {
                var ageDays = (DateTime.UtcNow.Date - m.ReleaseDate.Value.ToDateTime(TimeOnly.MinValue)).TotalDays;
                freshnessBoost = ageDays <= 365 ? 0.05 * (1.0 - Math.Clamp(ageDays / 365.0, 0.0, 1.0)) : 0.0;
            }

            var availabilityBoost = availabilityMap.TryGetValue(m.Id, out var avail) ? avail : 0.0;

            var score = 1.0 * sim + popularityBoost + freshnessBoost + availabilityBoost;
            if (score > 0)
                results.Add((m, score));
        }

        return results
            .OrderByDescending(x => x.score)
            .ThenBy(x => x.movie.Title)
            .Take(topN)
            .Select(x => ToDto(x.movie, x.score))
            .ToList();
    }

    public async Task<List<MovieScoreDto>> GetSimilarMovies(Guid movieId, int topN = 20, CancellationToken cancellationToken = default)
    {
        var movies = await _context.Movies
            .Include(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
            .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
            .Include(m => m.Director)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        var itemVectors = movies.ToDictionary(m => m.Id, BuildItemVector);
        if (!itemVectors.TryGetValue(movieId, out var target)) return new List<MovieScoreDto>();

        var results = new List<(Movie movie, double score)>();
        foreach (var m in movies)
        {
            if (m.Id == movieId) continue;
            var sim = Cosine(target, itemVectors[m.Id]);
            if (sim > 0)
                results.Add((m, sim));
        }

        return results
            .OrderByDescending(x => x.score)
            .ThenBy(x => x.movie.Title)
            .Take(topN)
            .Select(x => ToDto(x.movie, x.score))
            .ToList();
    }

    // --- Helpers ---

    private static Dictionary<string, double> BuildItemVector(Movie m)
    {
        var vec = new Dictionary<string, double>();
        foreach (var mg in m.MovieGenres)
        {
            if (mg.Genre != null)
            {
                var key = $"g:{mg.Genre.Id}";
                vec[key] = vec.GetValueOrDefault(key) + 1.0;
            }
        }
        foreach (var ma in m.MovieActors)
        {
            if (ma.Actor != null)
            {
                var key = $"a:{ma.Actor.Id}";
                vec[key] = vec.GetValueOrDefault(key) + 0.5;
            }
        }
        if (m.Director != null)
        {
            var key = $"d:{m.Director.Id}";
            vec[key] = vec.GetValueOrDefault(key) + 0.8;
        }
        Normalize(vec);
        return vec;
    }

    private static void AddScaled(Dictionary<string, double> acc, Dictionary<string, double>? vec, double weight)
    {
        if (vec == null || weight <= 0) return;
        foreach (var kv in vec)
        {
            acc[kv.Key] = acc.GetValueOrDefault(kv.Key) + kv.Value * weight;
        }
    }

    private static void Normalize(Dictionary<string, double> vec)
    {
        double norm = Math.Sqrt(vec.Values.Sum(v => v * v));
        if (norm <= 1e-9) return;
        var keys = vec.Keys.ToList();
        foreach (var k in keys)
            vec[k] = vec[k] / norm;
    }

    private static double Cosine(Dictionary<string, double> a, Dictionary<string, double> b)
    {
        if (a.Count == 0 || b.Count == 0) return 0.0;
        var smaller = a.Count <= b.Count ? a : b;
        var larger = ReferenceEquals(smaller, a) ? b : a;
        double dot = 0.0;
        foreach (var kv in smaller)
        {
            if (larger.TryGetValue(kv.Key, out var v))
                dot += kv.Value * v;
        }
        return dot;
    }

    private async Task<Dictionary<Guid, double>> GetPopularityScores(int daysBack, CancellationToken ct)
    {
        var since = DateTime.UtcNow.AddDays(-daysBack);
        var query = await _context.Reservations
            .Include(r => r.Projection)
            .Where(r => (r.IsCanceled == null || r.IsCanceled == false) && r.ReservedAt >= since)
            .GroupBy(r => r.Projection.MovieId)
            .Select(g => new { MovieId = g.Key, Count = g.Count() })
            .ToListAsync(ct);
        return query.ToDictionary(x => x.MovieId, x => (double)x.Count);
    }

    private async Task<Dictionary<Guid, double>> GetAvailabilityBoostMap(Guid cinemaId, DateTime to, CancellationToken ct)
    {
        var now = DateTime.UtcNow;
        var query = await _context.Projections
            .Include(p => p.Hall)
            .Where(p => p.Hall.CinemaId == cinemaId && p.StartTime >= now && p.StartTime <= to)
            .GroupBy(p => p.MovieId)
            .Select(g => new { MovieId = g.Key, Count = g.Count() })
            .ToListAsync(ct);
        return query.ToDictionary(x => x.MovieId, x => Math.Min(0.2, 0.05 + 0.03 * x.Count));
    }

    private static MovieScoreDto ToDto(Movie m, double score)
    {
        return new MovieScoreDto
        {
            MovieId = m.Id,
            Title = m.Title,
            PosterUrl = m.PosterUrl,
            Genres = m.MovieGenres.Select(mg => mg.Genre?.Name ?? string.Empty).Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList(),
            Director = m.Director?.FullName,
            TopActors = m.MovieActors.Select(ma => ma.Actor?.FullName ?? string.Empty).Where(s => !string.IsNullOrWhiteSpace(s)).Take(3).ToList(),
            Score = Math.Round(score, 4)
        };
    }
}
