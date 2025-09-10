using iCinema.Application.DTOs.Reports;
using MediatR;

namespace iCinema.Application.Features.Reports.Queries;

public record GenerateReportQuery(ReportRequestDto Request) : IRequest<ReportResponseDto>;
