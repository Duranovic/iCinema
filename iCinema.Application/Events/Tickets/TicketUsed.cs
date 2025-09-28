namespace iCinema.Application.Events.Tickets;

public record TicketUsed(
    Guid TicketId,
    Guid ReservationId,
    Guid UserId,
    Guid ProjectionId,
    DateTime UsedAt
);
