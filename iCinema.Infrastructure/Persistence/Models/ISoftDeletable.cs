namespace iCinema.Infrastructure.Persistence.Models;

/// <summary>
/// Interface for entities that support soft delete functionality.
/// </summary>
public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
    DateTime? DeletedAt { get; set; }
}

