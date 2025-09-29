namespace iCinema.Application.Interfaces.Services;

public interface IFileStorageService
{
    Task<string> SaveImageAsync(
        string category,
        string relativeFolder,
        string originalFileName,
        string contentType,
        long length,
        Stream stream,
        CancellationToken ct = default);
    
    Task<bool> DeleteByRelativeUrlAsync(string relativeUrl, CancellationToken ct = default);
}
