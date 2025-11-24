using iCinema.Application.DTOs.Reservations;

namespace iCinema.Application.Interfaces.Repositories;

public interface ITicketRepository
{
    Task<TicketQrDto?> GetQrAsync(Guid ticketId, Guid userId, CancellationToken cancellationToken = default);
    Task<TicketValidationResponseDto> ValidateAsync(string token, CancellationToken cancellationToken = default);
}
