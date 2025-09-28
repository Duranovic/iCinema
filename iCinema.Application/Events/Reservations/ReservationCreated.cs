namespace iCinema.Application.Events.Reservations;

public record ReservationCreated(
    Guid ReservationId,
    Guid UserId,
    Guid ProjectionId,
    string MovieTitle,
    DateTime StartTime,
    int TicketsCount
);
