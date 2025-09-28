namespace iCinema.Application.Interfaces.Services;

public interface IQrCodeService
{
    string GenerateToken(Guid ticketId, Guid projectionId, DateTime expiresAtUtc);
    bool TryValidate(string token, out Guid ticketId, out Guid projectionId, out DateTime expiresAtUtc, out string? error);
}
