using iCinema.Application.DTOs.Notifications;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class NotificationsRepository(iCinemaDbContext context, IUnitOfWork unitOfWork) : INotificationsRepository
{
    private readonly iCinemaDbContext _context = context;

    public async Task<IReadOnlyList<NotificationDto>> GetMyAsync(Guid userId, int top = 50, CancellationToken ct = default)
    {
        return await _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(top)
            .Select(n => new NotificationDto
            {
                Id = n.Id,
                Title = n.Title,
                Message = n.Message,
                CreatedAt = n.CreatedAt,
                IsRead = n.IsRead
            })
            .ToListAsync(ct);
    }

    public async Task MarkReadAsync(Guid userId, Guid notificationId, CancellationToken ct = default)
    {
        var n = await _context.Notifications.FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId, ct);
        if (n == null) return;
        n.IsRead = true;
        await unitOfWork.SaveChangesAsync(ct);
    }

    public async Task<NotificationDto> AddAsync(Guid userId, string title, string message, CancellationToken ct = default)
    {
        var n = new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Title = title,
            Message = message,
            CreatedAt = DateTime.UtcNow,
            IsRead = false
        };
        await _context.Notifications.AddAsync(n, ct);
        await unitOfWork.SaveChangesAsync(ct);
        
        return new NotificationDto
        {
            Id = n.Id,
            Title = n.Title,
            Message = n.Message,
            CreatedAt = n.CreatedAt,
            IsRead = n.IsRead
        };
    }

    public async Task<bool> DeleteAsync(Guid userId, Guid notificationId, CancellationToken ct = default)
    {
        var n = await _context.Notifications.FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId, ct);
        if (n == null) return false;
        _context.Notifications.Remove(n);
        await unitOfWork.SaveChangesAsync(ct);
        return true;
    }

    public async Task<int> DeleteAllAsync(Guid userId, CancellationToken ct = default)
    {
        var notifications = await _context.Notifications.Where(x => x.UserId == userId).ToListAsync(ct);
        var count = notifications.Count;
        _context.Notifications.RemoveRange(notifications);
        await unitOfWork.SaveChangesAsync(ct);
        return count;
    }
}
