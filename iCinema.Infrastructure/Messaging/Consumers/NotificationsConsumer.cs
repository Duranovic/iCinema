using iCinema.Application.Events.Reservations;
using iCinema.Application.Events.Tickets;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using MassTransit;

namespace iCinema.Infrastructure.Messaging.Consumers;

public class NotificationsConsumer :
    IConsumer<ReservationCreated>,
    IConsumer<ReservationCanceled>,
    IConsumer<TicketUsed>
{
    private readonly INotificationsRepository _notifications;
    private readonly INotificationsPushService _pushService;

    public NotificationsConsumer(
        INotificationsRepository notifications,
        INotificationsPushService pushService)
    {
        _notifications = notifications;
        _pushService = pushService;
    }

    public async Task Consume(ConsumeContext<ReservationCreated> context)
    {
        var e = context.Message;
        var title = "Rezervacija potvrđena";
        var body = $"Rezervacija #{e.ReservationId.ToString().Substring(0, 8)} za film '{e.MovieTitle}' na datum {e.StartTime:dd.MM.yyyy HH:mm}. Ulaznice: {e.TicketsCount}.";
        var notification = await _notifications.AddAsync(e.UserId, title, body, context.CancellationToken);
        await _pushService.PushToUserAsync(e.UserId, notification, context.CancellationToken);
    }

    public async Task Consume(ConsumeContext<ReservationCanceled> context)
    {
        var e = context.Message;
        var title = "Rezervacija otkazana";
        var body = $"Rezervacija #{e.ReservationId.ToString().Substring(0, 8)} je otkazana.";
        var notification = await _notifications.AddAsync(e.UserId, title, body, context.CancellationToken);
        await _pushService.PushToUserAsync(e.UserId, notification, context.CancellationToken);
    }

    public async Task Consume(ConsumeContext<TicketUsed> context)
    {
        var e = context.Message;
        var title = "Ulaznica iskorištena";
        var body = $"Ulaznica #{e.TicketId.ToString().Substring(0, 8)} je skenirana ({e.UsedAt:dd.MM.yyyy HH:mm}).";
        var notification = await _notifications.AddAsync(e.UserId, title, body, context.CancellationToken);
        await _pushService.PushToUserAsync(e.UserId, notification, context.CancellationToken);
    }
}
