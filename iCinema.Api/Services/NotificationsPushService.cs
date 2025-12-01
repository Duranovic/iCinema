using iCinema.Api.Hubs;
using iCinema.Application.DTOs.Notifications;
using iCinema.Application.Interfaces.Services;
using Microsoft.AspNetCore.SignalR;

namespace iCinema.Api.Services;

/// <summary>
/// Implementation of INotificationsPushService using SignalR
/// </summary>
public class NotificationsPushService : INotificationsPushService
{
    private readonly IHubContext<NotificationsHub> _hubContext;

    public NotificationsPushService(IHubContext<NotificationsHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public async Task PushToUserAsync(Guid userId, NotificationDto notification, CancellationToken ct = default)
    {
        // Send to user's group (user_{userId})
        await _hubContext.Clients.Group($"user_{userId}").SendAsync(
            "NewNotification",
            notification,
            ct);
    }
}



