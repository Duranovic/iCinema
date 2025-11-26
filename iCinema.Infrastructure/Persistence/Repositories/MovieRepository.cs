using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using iCinema.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using System;
using System.IO;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class MovieRepository(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork, IProjectionRulesService projectionRulesService, IFileStorageService fileStorageService, IMovieRulesService movieRulesService, IDirectorRulesService directorRulesService, ImageProcessingService imageProcessingService) : BaseRepository<Movie, MovieDto, MovieCreateDto, MovieUpdateDto>(context, mapper, unitOfWork), IMovieRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IMapper _mapper = mapper;
    private readonly IProjectionRulesService _projectionRulesService = projectionRulesService;
    private readonly IFileStorageService _fileStorageService = fileStorageService;
    private readonly IMovieRulesService _movieRulesService = movieRulesService;
    private readonly IDirectorRulesService _directorRulesService = directorRulesService;
    private readonly ImageProcessingService _imageProcessingService = imageProcessingService;
    protected override string[] SearchableFields => ["Title", "Description"];
    
    protected override IQueryable<Movie> AddInclude(IQueryable<Movie> query)
    {
        return query
            .Include(m => m.MovieGenres)
                .ThenInclude(mg => mg.Genre)
            .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
            .Include(m => m.Director)
            .Include(m => m.Ratings);
    }
    
    protected override IQueryable<Movie> AddFilter(IQueryable<Movie> query, BaseFilter baseFilter)
    {
        if (baseFilter is not MovieFilter filter) return query;
        
        if (filter.GenreId.HasValue)
            query = query.Where(m => m.MovieGenres.Any(mg => mg.GenreId == filter.GenreId));
        if (!string.IsNullOrWhiteSpace(filter.Title))
            query = query.Where(m => m.Title.Contains(filter.Title));
        return query;
    }
    
    protected override async Task BeforeInsert(Movie entity, MovieCreateDto dto)
    {
        if (dto.GenreIds.Count != 0)
        {
            entity.MovieGenres = await _context.Genres
                .Where(g => dto.GenreIds.Contains(g.Id))
                .Select(g => new MovieGenre { GenreId = g.Id, MovieId = entity.Id })
                .ToListAsync();
        }
    }

    // ---- Cast management ----
    public async Task<IEnumerable<CastItemDto>> GetCastAsync(Guid movieId, CancellationToken cancellationToken)
    {
        var movie = await DbSet
            .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
            .AsNoTracking()
            .FirstOrDefaultAsync(m => m.Id == movieId, cancellationToken);
        if (movie == null) return Enumerable.Empty<CastItemDto>();
        return movie.MovieActors
            .Select(ma => new CastItemDto
            {
                ActorId = ma.ActorId,
                ActorName = ma.Actor?.FullName ?? string.Empty,
                RoleName = ma.RoleName
            })
            .ToList();
    }

    public async Task AddCastAsync(Guid movieId, List<AddCastItem> items, CancellationToken cancellationToken)
    {
        var exists = await DbSet.AnyAsync(m => m.Id == movieId, cancellationToken);
        if (!exists) throw new BusinessRuleException("Film nije pronađen.");

        // Ensure unique by actor and skip existing links
        var actorIds = items.Select(i => i.ActorId).Distinct().ToList();
        var existingLinks = await _context.MovieActors
            .Where(ma => ma.MovieId == movieId && actorIds.Contains(ma.ActorId))
            .Select(ma => ma.ActorId)
            .ToListAsync(cancellationToken);

        var toAdd = items
            .Where(i => !existingLinks.Contains(i.ActorId))
            .Select(i => new MovieActor
            {
                MovieId = movieId,
                ActorId = i.ActorId,
                RoleName = i.RoleName
            })
            .ToList();

        if (toAdd.Count > 0)
        {
            _context.MovieActors.AddRange(toAdd);
            await unitOfWork.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task UpdateCastRoleAsync(Guid movieId, Guid actorId, string? roleName, CancellationToken cancellationToken)
    {
        var link = await _context.MovieActors.FirstOrDefaultAsync(ma => ma.MovieId == movieId && ma.ActorId == actorId, cancellationToken);
        if (link == null) throw new BusinessRuleException("Veza filma i glumca nije pronađena.");
        link.RoleName = roleName;
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }

    public async Task RemoveCastAsync(Guid movieId, Guid actorId, CancellationToken cancellationToken)
    {
        var link = await _context.MovieActors.FirstOrDefaultAsync(ma => ma.MovieId == movieId && ma.ActorId == actorId, cancellationToken);
        if (link == null) return;
        _context.MovieActors.Remove(link);
        await unitOfWork.SaveChangesAsync(cancellationToken);
    }
    public override async Task<MovieDto?> CreateAsync(MovieCreateDto dto, CancellationToken cancellationToken)
    {
        // Map basic properties
        var entity = _mapper.Map<Movie>(dto);

        // Validate AgeRating via rules service
        await _movieRulesService.EnsureValidAgeRating(entity.AgeRating, cancellationToken);

        // Validate Director existence if provided
        await _directorRulesService.EnsureDirectorExists(entity.DirectorId, cancellationToken);

        // Update genres
        entity.MovieGenres.Clear();
        if (dto.GenreIds.Count != 0)
        {
            entity.MovieGenres = await _context.Genres
                .Where(g => dto.GenreIds.Contains(g.Id))
                .Select(g => new MovieGenre { GenreId = g.Id, MovieId = entity.Id })
                .ToListAsync(cancellationToken);
        }

        DbSet.Add(entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);
        
        // Handle poster upload from base64 if provided
        if (!string.IsNullOrWhiteSpace(dto.PosterBase64) && !string.IsNullOrWhiteSpace(dto.PosterMimeType))
        {
            var (posterUrl, thumbnailUrl) = await SavePosterFromBase64Async(entity.Id, dto.PosterBase64!, dto.PosterMimeType!, cancellationToken);
            entity.PosterUrl = posterUrl;
            entity.ThumbnailUrl = thumbnailUrl;
            await unitOfWork.SaveChangesAsync(cancellationToken);
        }
        
        var createdEntity = await DbSet
            .Include(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
            .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
            .FirstOrDefaultAsync(m => m.Id == entity.Id, cancellationToken);
        return _mapper.Map<MovieDto>(createdEntity);
    }

    public override async Task<MovieDto?> UpdateAsync(Guid id, MovieUpdateDto dto, CancellationToken cancellationToken)
    {
        var entity = await DbSet
            .Include(m => m.MovieGenres)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
        if (entity == null) return null;

        // Map basic properties
        _mapper.Map(dto, entity);

        // Validate AgeRating via rules service
        await _movieRulesService.EnsureValidAgeRating(entity.AgeRating, cancellationToken);

        // Validate Director existence if provided
        await _directorRulesService.EnsureDirectorExists(entity.DirectorId, cancellationToken);

        // Update genres
        entity.MovieGenres.Clear();
        if (dto.GenreIds.Count != 0)
        {
            entity.MovieGenres = await _context.Genres
                .Where(g => dto.GenreIds.Contains(g.Id))
                .Select(g => new MovieGenre { GenreId = g.Id, MovieId = entity.Id })
                .ToListAsync(cancellationToken);
        }

        // Handle poster upload from base64 if provided
        if (!string.IsNullOrWhiteSpace(dto.PosterBase64) && !string.IsNullOrWhiteSpace(dto.PosterMimeType))
        {
            // Delete old poster and thumbnail
            if (!string.IsNullOrEmpty(entity.PosterUrl))
            {
                await _fileStorageService.DeleteByRelativeUrlAsync(entity.PosterUrl, cancellationToken);
            }
            if (!string.IsNullOrEmpty(entity.ThumbnailUrl))
            {
                await _fileStorageService.DeleteByRelativeUrlAsync(entity.ThumbnailUrl, cancellationToken);
            }
            var (posterUrl, thumbnailUrl) = await SavePosterFromBase64Async(id, dto.PosterBase64!, dto.PosterMimeType!, cancellationToken);
            entity.PosterUrl = posterUrl;
            entity.ThumbnailUrl = thumbnailUrl;
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
        
        var updatedEntity = await DbSet
            .Include(m => m.MovieGenres).ThenInclude(mg => mg.Genre)
            .Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);

        return _mapper.Map<MovieDto>(updatedEntity);
    }
    
    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var movie = await DbSet
            .Include(m => m.MovieGenres)
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);

        if (movie == null)
            return false;

        var hasFutureProjections = await _projectionRulesService.HasFutureProjectionsForMovie(movie.Id, cancellationToken);

        if (hasFutureProjections)
            throw new BusinessRuleException("Ne možete obrisati film koji ima zakazane buduće projekcije.");

        // Remove MovieGenres entries
        _context.MovieGenres.RemoveRange(movie.MovieGenres);

        DbSet.Remove(movie);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }


    private async Task<(string posterUrl, string thumbnailUrl)> SavePosterFromBase64Async(Guid movieId, string base64, string mimeType, CancellationToken ct)
    {
        // Strip possible data URI prefix
        var commaIdx = base64.IndexOf(',');
        if (commaIdx > 0 && base64[..commaIdx].Contains("base64", StringComparison.OrdinalIgnoreCase))
        {
            base64 = base64[(commaIdx + 1)..];
        }

        byte[] bytes;
        try
        {
            bytes = Convert.FromBase64String(base64);
        }
        catch (FormatException)
        {
            throw new BusinessRuleException("PosterBase64 je neispravan Base64 string.");
        }

        // Optional: size limit ~20MB
        const long maxBytes = 20L * 1024 * 1024;
        if (bytes.LongLength > maxBytes)
            throw new BusinessRuleException("Poster je prevelik (max 20MB).");

        // Validate image magic bytes
        var detectedMime = DetectImageMimeType(bytes);
        if (detectedMime == null)
            throw new BusinessRuleException("Datoteka nije validna slika.");
        
        // Verify declared MIME matches actual content
        if (!string.Equals(detectedMime, mimeType, StringComparison.OrdinalIgnoreCase))
            throw new BusinessRuleException($"MIME tip ({mimeType}) ne odgovara stvarnom sadržaju datoteke ({detectedMime}).");

        // Process main image: resize to max 1920x1080 and convert to WebP
        var mainImage = _imageProcessingService.ProcessImage(bytes, maxWidth: 1920, maxHeight: 1080, quality: 85);
        
        // Generate thumbnail: max 400x600
        var thumbnail = _imageProcessingService.GenerateThumbnail(bytes, maxWidth: 400, maxHeight: 600, quality: 80);

        // Save main poster
        await using var mainStream = new MemoryStream(mainImage.Bytes);
        var posterUrl = await _fileStorageService.SaveImageAsync(
            category: "movies",
            relativeFolder: movieId.ToString(),
            originalFileName: $"poster{mainImage.Extension}",
            contentType: mainImage.MimeType,
            length: mainImage.Bytes.LongLength,
            stream: mainStream,
            ct: ct);

        // Save thumbnail
        await using var thumbStream = new MemoryStream(thumbnail.Bytes);
        var thumbnailUrl = await _fileStorageService.SaveImageAsync(
            category: "movies",
            relativeFolder: movieId.ToString(),
            originalFileName: $"thumb{thumbnail.Extension}",
            contentType: thumbnail.MimeType,
            length: thumbnail.Bytes.LongLength,
            stream: thumbStream,
            ct: ct);

        return (posterUrl, thumbnailUrl);
    }

    /// <summary>
    /// Detects image MIME type by checking magic bytes (file signature)
    /// </summary>
    private static string? DetectImageMimeType(byte[] bytes)
    {
        if (bytes.Length < 12) return null;

        // JPEG: FF D8 FF
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF)
            return "image/jpeg";

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 &&
            bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A)
            return "image/png";

        // WebP: RIFF....WEBP
        if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
            bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50)
            return "image/webp";

        // GIF: GIF87a or GIF89a
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38 &&
            (bytes[4] == 0x37 || bytes[4] == 0x39) && bytes[5] == 0x61)
            return "image/gif";

        return null;
    }
}