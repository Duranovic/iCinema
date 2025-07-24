namespace iCinema.Application.Common.Models;

public class ApiError
{
    public int Status { get; set; }
    public string Error { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string TraceId { get; set; } = string.Empty;
    
    public IDictionary<string, string[]>? Details { get; set; } // for validation errors
}