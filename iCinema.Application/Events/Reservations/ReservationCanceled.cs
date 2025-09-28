namespace iCinema.Application.Events.Reservations;

public record ReservationCanceled(
    Guid ReservationId,
    Guid UserId,
    Guid ProjectionId,
    DateTime CanceledAt
);
