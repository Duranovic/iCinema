namespace iCinema.Infrastructure.Persistence.Models;

/// <summary>
/// Interface for entities that support audit tracking (CreatedAt/UpdatedAt).
/// </summary>
public interface IAuditable
{
    DateTime CreatedAt { get; set; }
    DateTime? UpdatedAt { get; set; }
}

