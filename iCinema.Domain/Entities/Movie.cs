using iCinema.Domain.Common;

namespace iCinema.Domain.Entities;

public class Movie(string title, int year, string description) : BaseEntity<Guid>
{
    public string Title { get; private set; } = title;
    public int Year { get; private set; } = year;
    public string Description { get; private set; } = description;
}