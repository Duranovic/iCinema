using iCinema.Application.Common.Models;
using iCinema.Application.DTOs.Reservations;

namespace iCinema.Application.Interfaces.Repositories;

public interface IReservationRepository
{
    Task<PagedResult<ReservationListItemDto>> GetMyReservations(
        Guid userId,
        string status, // "Active" | "Past"
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<List<TicketDto>> GetTicketsForReservation(
        Guid reservationId,
        Guid userId,
        CancellationToken cancellationToken = default);
}
