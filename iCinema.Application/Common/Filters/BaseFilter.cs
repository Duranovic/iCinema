namespace iCinema.Application.Common.Filters;

public class BaseFilter
{
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
    public string? SortBy { get; set; }
    public bool Descending { get; set; } = false;
}