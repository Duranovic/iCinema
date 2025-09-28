using System.Security.Cryptography;
using System.Text;
using iCinema.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace iCinema.Infrastructure.Services;

public class QrCodeService : IQrCodeService
{
    private readonly byte[] _secret;

    public QrCodeService(IConfiguration configuration)
    {
        // Load secret from configuration; fallback to a dev secret if not provided
        var secret = configuration["Qr:Secret"] ?? "icinemadev-secret-change";
        _secret = Encoding.UTF8.GetBytes(secret);
    }

    public string GenerateToken(Guid ticketId, Guid projectionId, DateTime expiresAtUtc)
    {
        var payload = $"{ticketId:N}|{projectionId:N}|{expiresAtUtc.Ticks}";
        var payloadBytes = Encoding.UTF8.GetBytes(payload);
        var sig = ComputeHmac(payloadBytes);
        return Base64Url(payloadBytes) + "." + Base64Url(sig);
    }

    public bool TryValidate(string token, out Guid ticketId, out Guid projectionId, out DateTime expiresAtUtc, out string? error)
    {
        ticketId = Guid.Empty;
        projectionId = Guid.Empty;
        expiresAtUtc = DateTime.MinValue;
        error = null;

        var parts = token.Split('.', 2);
        if (parts.Length != 2)
        {
            error = "Invalid token format";
            return false;
        }

        var payloadBytes = FromBase64Url(parts[0]);
        var sigBytes = FromBase64Url(parts[1]);
        var expectedSig = ComputeHmac(payloadBytes);
        if (!CryptographicOperations.FixedTimeEquals(sigBytes, expectedSig))
        {
            error = "Invalid signature";
            return false;
        }

        var payload = Encoding.UTF8.GetString(payloadBytes);
        var fields = payload.Split('|');
        if (fields.Length != 3)
        {
            error = "Invalid payload";
            return false;
        }

        if (!Guid.TryParseExact(fields[0], "N", out ticketId) || !Guid.TryParseExact(fields[1], "N", out projectionId))
        {
            error = "Invalid ids";
            return false;
        }

        if (!long.TryParse(fields[2], out var ticks))
        {
            error = "Invalid expiry";
            return false;
        }
        expiresAtUtc = new DateTime(ticks, DateTimeKind.Utc);

        if (expiresAtUtc <= DateTime.UtcNow)
        {
            error = "Token expired";
            return false;
        }

        return true;
    }

    private byte[] ComputeHmac(byte[] data)
    {
        using var hmac = new HMACSHA256(_secret);
        return hmac.ComputeHash(data);
    }

    private static string Base64Url(byte[] data) => Convert.ToBase64String(data)
        .TrimEnd('=')
        .Replace('+', '-')
        .Replace('/', '_');

    private static byte[] FromBase64Url(string s)
    {
        s = s.Replace('-', '+').Replace('_', '/');
        switch (s.Length % 4)
        {
            case 2: s += "=="; break;
            case 3: s += "="; break;
        }
        return Convert.FromBase64String(s);
    }
}
