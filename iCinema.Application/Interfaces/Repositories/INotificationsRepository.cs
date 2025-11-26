using iCinema.Application.DTOs.Notifications;

namespace iCinema.Application.Interfaces.Repositories;

public interface INotificationsRepository
{
    Task<IReadOnlyList<NotificationDto>> GetMyAsync(Guid userId, int top = 50, CancellationToken ct = default);
    Task MarkReadAsync(Guid userId, Guid notificationId, CancellationToken ct = default);
    Task<NotificationDto> AddAsync(Guid userId, string title, string message, CancellationToken ct = default);
    Task<bool> DeleteAsync(Guid userId, Guid notificationId, CancellationToken ct = default);
    Task<int> DeleteAllAsync(Guid userId, CancellationToken ct = default);
}
