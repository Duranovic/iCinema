using iCinema.Application.DTOs.Reports;

namespace iCinema.Application.Interfaces.Services;

public interface IReportsService
{
    Task<List<Dictionary<string, object>>> GenerateMovieReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken);
    Task<List<Dictionary<string, object>>> GenerateMovieSalesReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken);
    Task<List<Dictionary<string, object>>> GenerateHallReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken);
    Task<List<Dictionary<string, object>>> GenerateCinemaReservationsReportAsync(DateTime from, DateTime to, CancellationToken cancellationToken);
}
