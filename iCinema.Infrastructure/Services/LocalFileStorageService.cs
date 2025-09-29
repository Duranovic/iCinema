using iCinema.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace iCinema.Infrastructure.Services;

public class LocalFileStorageService : IFileStorageService
{
    private readonly string _rootPath;
    private readonly string _baseUrlPath;
    private readonly long _maxBytes;
    private readonly HashSet<string> _allowedTypes;

    public LocalFileStorageService(IConfiguration config)
    {
        _rootPath = config["FileStorage:RootPath"] ?? "uploads";
        _baseUrlPath = config["FileStorage:BaseUrlPath"] ?? "/media";
        if (!Path.IsPathRooted(_rootPath))
        {
            _rootPath = Path.Combine(Directory.GetCurrentDirectory(), _rootPath);
        }
        Directory.CreateDirectory(_rootPath);

        var maxMb = int.TryParse(config["FileStorage:MaxSizeMB"], out var m) ? m : 10;
        _maxBytes = maxMb * 1024L * 1024L;

        var types = (config.GetSection("FileStorage:AllowedTypes").Get<string[]>() ?? ["image/jpeg", "image/png", "image/webp"]).ToList();
        _allowedTypes = new HashSet<string>(types, StringComparer.OrdinalIgnoreCase);
    }

    public async Task<string> SaveImageAsync(
        string category,
        string relativeFolder,
        string originalFileName,
        string contentType,
        long length,
        Stream stream,
        CancellationToken ct = default)
    {
        if (!_allowedTypes.Contains(contentType))
            throw new InvalidOperationException($"Nedozvoljen tip datoteke: {contentType}");
        if (length <= 0 || length > _maxBytes)
            throw new InvalidOperationException("Veličina datoteke nije dozvoljena");

        // choose extension by original name (fallback from content-type)
        var ext = Path.GetExtension(originalFileName);
        if (string.IsNullOrWhiteSpace(ext))
        {
            ext = contentType switch
            {
                "image/jpeg" => ".jpg",
                "image/png" => ".png",
                "image/webp" => ".webp",
                _ => ".bin"
            };
        }

        var safeExt = ext.Trim().ToLowerInvariant();
        var fileName = $"{Guid.NewGuid():N}{safeExt}";
        var folder = Path.Combine(_rootPath, category, relativeFolder);
        Directory.CreateDirectory(folder);
        var fullPath = Path.Combine(folder, fileName);

        await using (var fs = File.Create(fullPath))
        {
            await stream.CopyToAsync(fs, ct);
        }

        // Return relative URL path, e.g. /media/movies/{id}/{file}
        var relativeUrl = $"{_baseUrlPath}/{category}/{relativeFolder}/{fileName}".Replace("\\", "/");
        return relativeUrl;
    }

    public Task<bool> DeleteByRelativeUrlAsync(string relativeUrl, CancellationToken ct = default)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return Task.FromResult(false);
            var url = relativeUrl.Replace("\\", "/");
            var basePath = _baseUrlPath.TrimEnd('/');
            if (!url.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
                return Task.FromResult(false);

            var tail = url.Substring(basePath.Length).TrimStart('/');
            var fullPath = Path.Combine(_rootPath, tail.Replace('/', Path.DirectorySeparatorChar));
            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                return Task.FromResult(true);
            }
            return Task.FromResult(false);
        }
        catch
        {
            return Task.FromResult(false);
        }
    }
}
