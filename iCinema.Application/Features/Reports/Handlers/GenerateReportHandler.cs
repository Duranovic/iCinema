using iCinema.Application.DTOs.Reports;
using iCinema.Application.Features.Reports.Queries;
using iCinema.Application.Interfaces.Services;
using MediatR;

namespace iCinema.Application.Features.Reports.Handlers;

public class GenerateReportHandler(IReportsService reportsService) : IRequestHandler<GenerateReportQuery, ReportResponseDto>
{
    public async Task<ReportResponseDto> Handle(GenerateReportQuery request, CancellationToken cancellationToken)
    {
        var dto = request.Request;
        
        // Validate date range
        if (dto.DateFrom > dto.DateTo)
            throw new ArgumentException("DateFrom must be less than or equal to DateTo");

        var response = new ReportResponseDto
        {
            ReportType = dto.ReportType,
            Period = new ReportPeriodDto
            {
                From = dto.DateFrom,
                To = dto.DateTo
            }
        };

        response.Data = dto.ReportType switch
        {
            ReportType.MovieReservations => await reportsService.GenerateMovieReservationsReportAsync(dto.DateFrom, dto.DateTo, cancellationToken),
            ReportType.MovieSales => await reportsService.GenerateMovieSalesReportAsync(dto.DateFrom, dto.DateTo, cancellationToken),
            ReportType.HallReservations => await reportsService.GenerateHallReservationsReportAsync(dto.DateFrom, dto.DateTo, cancellationToken),
            ReportType.CinemaReservations => await reportsService.GenerateCinemaReservationsReportAsync(dto.DateFrom, dto.DateTo, cancellationToken),
            _ => throw new ArgumentException($"Unsupported report type: {dto.ReportType}")
        };

        return response;
    }
}
