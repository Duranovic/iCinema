using iCinema.Application.DTOs.Notifications;

namespace iCinema.Application.Interfaces.Services;

/// <summary>
/// Service for pushing real-time notifications to connected clients
/// </summary>
public interface INotificationsPushService
{
    /// <summary>
    /// Push a notification to a specific user via SignalR
    /// </summary>
    Task PushToUserAsync(Guid userId, NotificationDto notification, CancellationToken ct = default);
}



