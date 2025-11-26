using SkiaSharp;

namespace iCinema.Infrastructure.Services;

/// <summary>
/// Service for image processing: resizing and format conversion
/// </summary>
public class ImageProcessingService
{
    /// <summary>
    /// Resize image to fit within max dimensions while maintaining aspect ratio,
    /// and convert to WebP format
    /// </summary>
    public ImageResult ProcessImage(
        byte[] sourceBytes,
        int maxWidth = 1920,
        int maxHeight = 1080,
        int quality = 85)
    {
        using var sourceBitmap = SKBitmap.Decode(sourceBytes);
        if (sourceBitmap == null)
            throw new InvalidOperationException("Nije moguće dekodirati sliku.");

        var (newWidth, newHeight) = CalculateDimensions(
            sourceBitmap.Width, 
            sourceBitmap.Height, 
            maxWidth, 
            maxHeight);

        using var resizedBitmap = sourceBitmap.Resize(
            new SKImageInfo(newWidth, newHeight), 
            SKSamplingOptions.Default);
        
        if (resizedBitmap == null)
            throw new InvalidOperationException("Nije moguće promijeniti veličinu slike.");

        using var image = SKImage.FromBitmap(resizedBitmap);
        using var data = image.Encode(SKEncodedImageFormat.Webp, quality);

        return new ImageResult
        {
            Bytes = data.ToArray(),
            MimeType = "image/webp",
            Extension = ".webp",
            Width = newWidth,
            Height = newHeight
        };
    }

    /// <summary>
    /// Generate a thumbnail version of the image
    /// </summary>
    public ImageResult GenerateThumbnail(
        byte[] sourceBytes,
        int maxWidth = 400,
        int maxHeight = 600,
        int quality = 80)
    {
        return ProcessImage(sourceBytes, maxWidth, maxHeight, quality);
    }

    private static (int width, int height) CalculateDimensions(
        int originalWidth, 
        int originalHeight, 
        int maxWidth, 
        int maxHeight)
    {
        if (originalWidth <= maxWidth && originalHeight <= maxHeight)
            return (originalWidth, originalHeight);

        var ratioX = (double)maxWidth / originalWidth;
        var ratioY = (double)maxHeight / originalHeight;
        var ratio = Math.Min(ratioX, ratioY);

        var newWidth = (int)(originalWidth * ratio);
        var newHeight = (int)(originalHeight * ratio);

        return (newWidth, newHeight);
    }
}

public class ImageResult
{
    public required byte[] Bytes { get; init; }
    public required string MimeType { get; init; }
    public required string Extension { get; init; }
    public int Width { get; init; }
    public int Height { get; init; }
}

