namespace iCinema.Application.DTOs.Reports;

public class ReportResponseDto
{
    public ReportType ReportType { get; set; }
    public ReportPeriodDto Period { get; set; } = new();
    public List<Dictionary<string, object>> Data { get; set; } = new();
}

public class ReportPeriodDto
{
    public DateTime From { get; set; }
    public DateTime To { get; set; }
}
