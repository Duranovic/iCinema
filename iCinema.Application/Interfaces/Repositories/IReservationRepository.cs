using iCinema.Application.Common.Models;
using iCinema.Application.DTOs.Reservations;

namespace iCinema.Application.Interfaces.Repositories;

public interface IReservationRepository
{
    Task<SeatMapDto?> GetSeatMapAsync(
        Guid projectionId,
        CancellationToken cancellationToken = default);

    Task<ReservationCreatedDto> CreateAsync(
        Guid userId,
        ReservationCreateDto dto,
        CancellationToken cancellationToken = default);

    Task<bool> CancelAsync(
        Guid userId,
        Guid reservationId,
        CancellationToken cancellationToken = default);

    Task<PagedResult<ReservationListItemDto>> GetMyReservationsAsync(
        Guid userId,
        string status, // "Active" | "Past"
        int page,
        int pageSize,
        CancellationToken cancellationToken = default);

    Task<List<TicketDto>> GetTicketsForReservationAsync(
        Guid reservationId,
        Guid userId,
        CancellationToken cancellationToken = default);
}
